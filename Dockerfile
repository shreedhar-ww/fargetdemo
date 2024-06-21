#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Fargate-Demo/Fargate-Demo.csproj", "Fargate-Demo/"]
RUN dotnet restore "./Fargate-Demo/Fargate-Demo.csproj"
COPY . .
WORKDIR "/src/Fargate-Demo"
RUN dotnet build "./Fargate-Demo.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish


# Update the package list and install required packages
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    build-essential

# Add NodeSource APT repository for Node 16.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Install Node.js
RUN apt-get install -y nodejs

ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Fargate-Demo.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Fargate-Demo.dll"]