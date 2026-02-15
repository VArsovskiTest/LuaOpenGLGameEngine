using System;
using System.IO;

public class LogHelper : IDisposable
{
    private readonly string _logFilePath;
    private readonly object _lock = new object();
    private bool _disposed = false;

    /// <summary>
    /// Initializes a new instance of the LogHelper class.
    /// </summary>
    /// <param name="logFileName">The name of the log file (e.g., "engine.log"). 
    /// It will be placed in a 'logs' subdirectory.</param>
    public LogHelper(string logFileName)
    {
        if (string.IsNullOrWhiteSpace(logFileName))
        {
            throw new ArgumentNullException(nameof(logFileName), "Log file name cannot be null or empty.");
        }

        // Ensure the log directory exists
        string logDirectory = "logs";
        try
        {
            if (!Directory.Exists(logDirectory))
            {
                Directory.CreateDirectory(logDirectory);
            }
        }
        catch (Exception ex)
        {
            // Fallback to console if directory creation fails
            Console.WriteLine($"FATAL: Could not create log directory '{logDirectory}'. Error: {ex.Message}");
        }

        // Combine the directory and file name to get the full path
        _logFilePath = Path.Combine(logDirectory, logFileName);
    }

    /// <summary>
    /// Writes a message to the log file with a timestamp.
    /// </summary>
    /// <param name="message">The message to log.</param>
    /// <param name="level">The log level (e.g., INFO, ERROR, HOOK).</param>
    public void Log(string message, string level = "INFO")
    {
        if (_disposed)
        {
            // Or throw an ObjectDisposedException
            Console.WriteLine("WARNING: Attempted to log to a disposed LogHelper instance.");
            return;
        }

        try
        {
            string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}] [{level}] {message}{Environment.NewLine}";

            lock (_lock)
            {
                File.AppendAllText(_logFilePath, logEntry);
            }
        }
        catch (Exception ex)
        {
            // If file writing fails, fall back to the console
            Console.WriteLine($"ERROR: Could not write to log file '{_logFilePath}'. Error: {ex.Message}");
            Console.WriteLine($"Original Message: [{level}] {message}");
        }
    }

    /// <summary>
    /// Convenience method for logging an error.
    /// </summary>
    public void LogError(string message)
    {
        Log(message, "ERROR");
    }

    /// <summary>
    /// Convenience method for logging a debug message.
    /// </summary>
    public void LogDebug(string message)
    {
        Log(message, "DEBUG");
    }

    public void Dispose()
    {
        // In this simple implementation, we don't have unmanaged resources to free,
        // but it's good practice to implement IDisposable if you have a class
        // that manages a resource like a file stream (which we don't, we use File.AppendAllText).
        // We'll use it to prevent logging after disposal.
        _disposed = true;
    }
}
