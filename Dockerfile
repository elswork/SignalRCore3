FROM ${BASEIMAGE} AS base
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

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL mantainer="Eloy Lopez <elswork@gmail.com>" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="theia" \
    org.label-schema.description="Multiarch Net Core 3 With SignalR for amd64 arm32v7 or arm64" \
    org.label-schema.url="https://deft.work/SignalRCore3" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/elswork/SignalRCore3" \
    org.label-schema.vendor="Deft Work" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SignalRCore3.dll"]