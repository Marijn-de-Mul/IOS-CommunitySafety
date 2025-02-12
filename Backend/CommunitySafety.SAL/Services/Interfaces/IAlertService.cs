using CommunitySafety.SAL.Models;

namespace CommunitySafety.SAL.Services.Interfaces;

public interface IAlertService
{
    public Task SendAlert(AlertRequest request);
}