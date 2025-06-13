using Azure.Data.Tables;
using Microsoft.Extensions.Configuration;      // ← DOPISZ TO

public class StorageCtx
{
    public TableClient Tbl { get; }

    public StorageCtx(IConfiguration cfg)
    {
        // connection-string z app-settings + nazwa tabeli „Tasks”
        Tbl = new TableClient(cfg["StorageConn"], "Tasks");
        Tbl.CreateIfNotExists();
    }
}
