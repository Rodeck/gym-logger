using System.Threading.Tasks;
using FirebaseAdmin.Auth;

namespace Gym.E2E;

public static class FirebaseAuthExtensions
{
    public static async Task EnsureUserExists(this FirebaseAdmin.Auth.FirebaseAuth auth, EndpointsConfig config)
    {
        try
        {
            var user = await auth.GetUserByEmailAsync(config.UserEmail);
        }
        catch (FirebaseAdmin.Auth.FirebaseAuthException ex)
        {
            await auth.CreateUserAsync(new UserRecordArgs()
            {
                Email = config.UserEmail,
                EmailVerified = true,
                Password = config.UserPassword,
                DisplayName = "Test User",
                Disabled = false,
            });
        }
    }
}
