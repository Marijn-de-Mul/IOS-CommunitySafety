FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["CommunitySafety.API/CommunitySafety.API.csproj", "CommunitySafety.API/"]
COPY ["CommunitySafety.SAL/CommunitySafety.SAL.csproj", "CommunitySafety.SAL/"]
COPY ["CommunitySafety.DAL/CommunitySafety.DAL.csproj", "CommunitySafety.DAL/"]
RUN dotnet restore "CommunitySafety.API/CommunitySafety.API.csproj"
COPY . .
WORKDIR "/src/CommunitySafety.API"
RUN dotnet build "CommunitySafety.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "CommunitySafety.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CommunitySafety.API.dll"]
