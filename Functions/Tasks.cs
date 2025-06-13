using System.Net;
using System.Collections.Generic;
using System.Threading.Tasks;
using Azure;                       // ETag
using Azure.Data.Tables;           // TableClient / QueryAsync
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;

record TodoDto(string id, string text);

public class Tasks
{
    private readonly StorageCtx _ctx;
    public Tasks(StorageCtx ctx) => _ctx = ctx;

    // POST  /api/tasks   { "text": "Kup mleko" }
    [Function("AddTask")]
    public async Task<HttpResponseData> Add(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "tasks")]
        HttpRequestData req)
    {
        var body = await req.ReadFromJsonAsync<TodoDto>() ?? new("", "");
        if (string.IsNullOrWhiteSpace(body.text))
            return req.CreateResponse(HttpStatusCode.BadRequest);

        var entity = new TodoItem { Text = body.text };
        await _ctx.Tbl.AddEntityAsync(entity);

        var res = req.CreateResponse(HttpStatusCode.Created);
        await res.WriteAsJsonAsync(new TodoDto(entity.RowKey, entity.Text));
        return res;
    }

    // GET  /api/tasks
    [Function("GetTasks")]
    public async Task<HttpResponseData> List(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "tasks")]
        HttpRequestData req)
    {
        var list = new List<TodoDto>();

        // iterujemy asynchronicznie po wyniku zapytania
        await foreach (TodoItem e in _ctx.Tbl.QueryAsync<TodoItem>())
            list.Add(new TodoDto(e.RowKey, e.Text));

        var res = req.CreateResponse(HttpStatusCode.OK);
        await res.WriteAsJsonAsync(list);
        return res;
    }

    // DELETE  /api/tasks/{id}
    [Function("DeleteTask")]
    public async Task<HttpResponseData> Delete(
        [HttpTrigger(AuthorizationLevel.Function, "delete", Route = "tasks/{id}")]
        HttpRequestData req, string id)
    {
        await _ctx.Tbl.DeleteEntityAsync("todo", id, ETag.All);
        return req.CreateResponse(HttpStatusCode.NoContent);
    }
}
