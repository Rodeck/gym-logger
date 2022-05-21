using Microsoft.Extensions.Configuration;

namespace Gym.E2E;

public static class ConfigurationBuilder
{
    public static IConfiguration Build()
    {
        return new Microsoft.Extensions.Configuration.ConfigurationBuilder()
            .AddJsonFile("appsettings.json")
            .AddEnvironmentVariables()
            .Build();
    }
}
