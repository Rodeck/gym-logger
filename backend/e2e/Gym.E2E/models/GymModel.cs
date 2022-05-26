using System;
using System.Text.Json.Serialization;

namespace Gym.E2E;

public class GymModel
{
    public string Name { get; set; }

    public double Lat { get; set; }

    public double Lng { get; set; }

    public DateTime CreatedDate { get; set; }

    public string UserId { get; set; }

    [JsonPropertyName("_id")]
    public string Id { get; set; }
}
