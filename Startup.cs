using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

public class Startup
{
    public IConfiguration Configuration { get; private set; }

    /// <summary>
    /// Builds the configuration (appsettings.json, environment, etc.)
    /// </summary>
    public void ConfigureConfiguration(HostBuilderContext context, ConfigurationBuilder builder)
    {
        builder
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .AddJsonFile($"appsettings.{context.HostingEnvironment.EnvironmentName}.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables();
    }

    /// <summary>
    /// Called after the host is built — store the configuration
    /// </summary>
    public void Configure(IConfiguration configuration)
    {
        Configuration = configuration;
    }
}
