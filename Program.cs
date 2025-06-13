using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    // ✅ rejestruje runtime Functions isolated (v4, .NET 8)
    .ConfigureFunctionsWorkerDefaults()

    // ✅ nasze zależności
    .ConfigureServices(services =>
    {
        services.AddSingleton<StorageCtx>();                     // helper do Table Storage
        services.AddApplicationInsightsTelemetryWorkerService(); // logi AI (opcjonalnie)
    })

    .Build();

host.Run();