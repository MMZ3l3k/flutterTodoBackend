using Azure;
using Azure.Data.Tables;

public class TodoItem : ITableEntity   // ← też „public”
{
    public string PartitionKey { get; set; } = "todo";
    public string RowKey      { get; set; } = Guid.NewGuid().ToString();
    public string Text        { get; set; } = string.Empty;
    public DateTimeOffset? Timestamp { get; set; }
    public ETag ETag { get; set; }
}
