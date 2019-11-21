FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ["SignalRCore3.csproj", ""]
RUN dotnet restore "./SignalRCore3.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "SignalRCore3.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SignalRCore3.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SignalRCore3.dll"]