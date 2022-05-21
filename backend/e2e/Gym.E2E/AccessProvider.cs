using System;
using System.Threading.Tasks;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Options;
using Firebase.Auth;

namespace Gym.E2E;

public class AccessProvider : IAccessProvider
{
    private readonly IOptions<EndpointsConfig> options;
    private string CachedToken;

    public AccessProvider(IOptions<EndpointsConfig> options)
    {
        this.options = options;
    }

    public async Task<string> GetToken()
    {
        if (!string.IsNullOrEmpty(CachedToken))
        {
            return CachedToken;
        }

        var defaultAuth = FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance;

        if (defaultAuth == null) 
        {
            var app = FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.GetApplicationDefault(),
            });

            defaultAuth = FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance;
        }

        if (defaultAuth == null)
        {
            throw new InvalidOperationException("Default auth not found.");
        }

        await defaultAuth.EnsureUserExists(options.Value);
        var token = await GetTokenInternal(options.Value);
        CachedToken = token;

        return CachedToken;
    }

    private async Task<string> GetTokenInternal(EndpointsConfig config)
    {
        var authProvider = new FirebaseAuthProvider(new FirebaseConfig(config.FirebaseGymApiKey));

        var auth = await authProvider.SignInWithEmailAndPasswordAsync(config.UserEmail, config.UserPassword);
        return auth.FirebaseToken;
    }
}
