using StackExchange.Redis;
using Microsoft.Extensions.Configuration;

public class RedisConfig
{
    private ConnectionMultiplexer? _connection;
    private bool _initialized = false;
    private bool _redisEnabledInConfig = false;

    public IDatabase? Database => _connection?.GetDatabase();
    public ISubscriber? Subscriber => _connection?.GetSubscriber();

    /// <summary>
    /// Call this once at application startup (e.g., in Program.cs or GameEngine init)
    /// </summary>
    public void InitializeRedis(IConfiguration configuration)
    {
        if (_initialized)
            return; // Already initialized

        var redisSection = configuration.GetSection("Redis");

        _redisEnabledInConfig = redisSection.GetValue<bool>("Enabled", false);

        if (!_redisEnabledInConfig)
        {
            Console.WriteLine("Redis is disabled in configuration.");
            _initialized = true;
            return;
        }

        var connectionString = redisSection["ConnectionString"];
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            Console.WriteLine("Redis connection string is missing or empty.");
            _initialized = true;
            return;
        }

        try
        {
            var options = ConfigurationOptions.Parse(connectionString);
            options.AbortOnConnectFail = false; // Don't crash app if Redis is down
            options.ConnectRetry = 5;
            options.ReconnectRetryPolicy = new ExponentialRetry(500, 10000);

            _connection = ConnectionMultiplexer.Connect(options);

            // Quick test to see if it's immediately usable
            _connection.GetDatabase().Ping();

            Console.WriteLine("Redis connected successfully.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Redis connection failed: {ex.Message}");
            Console.WriteLine("Redis will be treated as unavailable.");
            _connection = null;
        }

        _initialized = true;
    }

    /// <summary>
    /// Returns true if Redis is enabled and currently connected
    /// Safe to call anytime — checks both config and live connection
    /// </summary>
    public bool IsAvailable()
    {
        if (!_initialized || !_redisEnabledInConfig)
            return false;

        return _connection != null && _connection.IsConnected;
    }
}
