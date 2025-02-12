using CommunitySafety.DAL;
using CommunitySafety.DAL.Repositories;
using CommunitySafety.SAL.Interfaces;
using CommunitySafety.SAL.Models;
using CommunitySafety.SAL.Repositories;
using CommunitySafety.SAL.Services;
using CommunitySafety.SAL.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

builder.Services.AddScoped<IAlertService, AlertService>(); 
builder.Services.AddScoped<IAlertRepository, AlertRepository>(); 

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();