using NLua;
using System;
using System.Collections.Generic;
using StackExchange.Redis;
using System.Text.Json;

public class RedisQueue
{
    private readonly IDatabase _db;
    private readonly ISubscriber _sub;
    private readonly RedisConfig _redisConfig;
    private Lua _lua { get; set; }
    private LogHelper _logger { get; set; }

    private static readonly Lazy<ConnectionMultiplexer> LazyConnection =
        new Lazy<ConnectionMultiplexer>(() => ConnectionMultiplexer.Connect("localhost:6379"));
    private static ConnectionMultiplexer Connection => LazyConnection.Value;

    // private bool IsRedisEnabled() => _redisEnabled && _connection != null && _connection.IsConnected;

    private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true
    };

    public RedisQueue(RedisConfig redisConfig, Lua lua)
    {
        _redisConfig = redisConfig;

        if (_redisConfig.IsAvailable())
        {
            _db = Connection.GetDatabase();
            _sub = Connection.GetSubscriber();
        }
        // TODO: else save temporarily in file..

        _lua = lua;
        _logger = new LogHelper("redis_queue.log");
    }

    public bool Enqueue(string queueName, object luaTable)
    {
        _logger.Log($"[C# Hook] Lua called redis_enqueue for queue '{queueName}' with data: {JsonSerializer.Serialize(luaTable)}");
        try
        {
            var dict = LuaHelper.LuaTableToDictionary(new object[] { luaTable });
            string json = JsonSerializer.Serialize(dict, JsonOptions);

            _db.ListRightPush(queueName, json);

            // Notify waiting consumers
            _sub.Publish(queueName + ":notify", "");

            return true;
        }
        catch
        {
            return false;
        }
    }

    public object Dequeue(string queueName, double timeoutSeconds = 0)
    {
        _logger.Log($"[C# Hook] Lua called redis_enqueue for dequeue '{queueName}'");
        try
        {
            // First, try non-blocking pop
            RedisValue value = _db.ListLeftPop(queueName);
            if (!value.IsNullOrEmpty)
            {
                string json = value;
                var dict = JsonSerializer.Deserialize<Dictionary<string, object>>(json, JsonOptions);
                return dict;
            }

            if (timeoutSeconds <= 0)
                return null; // Non-blocking requested

            // Wait for notification or timeout
            var channel = _sub.Subscribe(queueName + ":notify");

            bool gotItem = false;
            RedisValue finalValue = RedisValue.Null;

            channel.OnMessage(msg =>
            {
                // Notification received - try to pop
                finalValue = _db.ListLeftPop(queueName);
                gotItem = true;
            });

            // Wait for notification or timeout
            var start = DateTime.UtcNow;
            while ((DateTime.UtcNow - start).TotalSeconds < timeoutSeconds)
            {
                if (gotItem && !finalValue.IsNullOrEmpty)
                    break;

                Thread.Sleep(100); // Small sleep to avoid busy loop
            }

            channel.Unsubscribe();

            if (finalValue.IsNullOrEmpty)
                return null;

            string finalJson = finalValue;
            _logger.Log($"[C# Hook] Lua called redis_enqueue for dequeue '{queueName} and retrieved value: ' {finalJson}");

            var finalDict = JsonSerializer.Deserialize<Dictionary<string, object>>(finalJson, JsonOptions);
            return finalDict;
        }
        catch
        {
            return null;
        }
    }

    public void Clear(string queueName)
    {
        _db.KeyDelete(queueName);
    }

    public void SetupBindings()
    {
        _lua["get_logs_path"] = (Func<string, string>)((filename) =>
        {
            string projectRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", ".."));
            var logsDir = Path.Combine(projectRoot, "logs");

            // Ensure the logs directory exists
            if (!Directory.Exists(logsDir))
                Directory.CreateDirectory(logsDir);

            return Path.Combine(logsDir, filename);
        });

        if (_redisConfig.IsAvailable())
        {
            _lua["_redis_enqueue"] = (Func<string, object, bool>)Enqueue;
            _lua["_redis_dequeue"] = (Func<string, double, object>)Dequeue;
            _lua["_redis_clear"] = (Action<string>)Clear;

            // Register functions to Lua
            _lua.DoString(@"
                redis_enqueue = function(queue_name, command_table)
                    return _redis_enqueue(queue_name, command_table)
                end
                redis_dequeue = function(queue_name, timeout_seconds)
                    return _redis_dequeue(queue_name, timeout_seconds or 0)
                end
                redis_clear = function(queue_name)
                    _redis_clear(queue_name)
                end
            ");
        }
    }
}
