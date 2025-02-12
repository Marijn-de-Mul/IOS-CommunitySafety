using CommunitySafety.SAL.Models;

namespace CommunitySafety.SAL.Interfaces;

public interface IAlertRepository
{
    public Task AddAlert(Alert alert); 
}