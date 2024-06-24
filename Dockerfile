# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Node.js build stage
FROM node:18-alpine AS node-build
WORKDIR /src
COPY ["Fargate-Demo/clientapp/", "Fargate-Demo/clientapp/"]
WORKDIR "/src/Fargate-Demo/clientapp/"
RUN npm install
RUN npm run build

# .NET build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Fargate-Demo/Fargate-Demo.csproj", "Fargate-Demo/"]
RUN dotnet restore "./Fargate-Demo/Fargate-Demo.csproj"
COPY . .
WORKDIR "/src/Fargate-Demo"
RUN dotnet build "./Fargate-Demo.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
# Copy the built Node.js app
COPY --from=node-build /src/Fargate-Demo/wwwroot ./wwwroot
RUN dotnet publish "./Fargate-Demo.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Fargate-Demo.dll"]