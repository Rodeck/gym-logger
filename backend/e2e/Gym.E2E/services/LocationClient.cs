using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;

namespace Gym.E2E
{
    internal class VisitClient : IVisitsService
    {
        private readonly IAccessProvider accessProvider;
        private readonly IHttpClientFactory clientFactory;
        private readonly IOptions<VisitConfig> options;

        public VisitClient(IAccessProvider accessProvider, IHttpClientFactory clientFactory, IOptions<VisitConfig> options)
        {
            this.accessProvider = accessProvider;
            this.clientFactory = clientFactory;
            this.options = options;
        }

        public async Task CreateVisit(string gymId, Coordinates coordinates)
        {
            if (string.IsNullOrEmpty(gymId))
            {
                throw new ArgumentNullException(nameof(gymId));
            }
            
            var endpoint = $"{options.Value.Endpoint}/";
            using var client = clientFactory.CreateClient();
            await accessProvider.Authorize(client);

            var response = await client.PostAsJsonAsync(endpoint, new VisitModel
            {
                GymId = gymId,
                Lat = coordinates.Lat,
                Lng = coordinates.Lng,
            });

            response.EnsureSuccessStatusCode();
        }

        public async Task<IEnumerable<VisitModel>> GetUserVisits()
        {
            var endpoint = $"{options.Value.Endpoint}/";
            using var client = clientFactory.CreateClient();
            await accessProvider.Authorize(client);

            return await client.GetFromJsonAsync<IEnumerable<VisitModel>>(endpoint);
        }
    }
}