/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProj..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProj..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProj..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProj..CovidDeaths
Where location like 'Alg%'
order by 1,2

--Highest Number of infection per country & percetange of cases

Select Location, Population, MAX(total_cases) as highest_numbers_cases, MAX((total_cases/population))*100 as Percent_Population_Infected
From PortfolioProj..CovidDeaths
--Where location like 'Alg%'
GROUP By Population, location
order by Percent_Population_Infected DESC

-- Death count per country
Select Location, Population, MAX(total_deaths) as Count_deaths_cases, MAX((total_deaths/population))*100 as Percent_Population_Deaths
From PortfolioProj..CovidDeaths
Where location like 'Alg%'
GROUP By Population, location
order by Percent_Population_Deaths DESC

-- Total Deaths in Home Country

Select MAX(CAST(total_deaths as int)) total_death_count 
FROM Portfolioproj..CovidDeaths 
Where Location like 'ALG%'

-- Total deaths per country

Select Location, MAX(CAST(total_deaths as int)) total_death_count 
FROM Portfolioproj..CovidDeaths 
Where continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Total Deaths per continent
Select location, MAX(CAST(total_deaths as int)) total_death_count 
FROM Portfolioproj..CovidDeaths 
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count;

-- Global Numbers 

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProj..CovidDeaths
where continent is not null 
Group By date
order by 1,2

-- SUM of deaths

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProj..CovidDeaths
where continent is not null 
order by 1,2

--Total population vs new_vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentages
From PopvsVac

--Creating TEMP table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Percentageofvaccination
From #PercentPopulationVaccinated

-- Population_vaccinated VIEW for VIZ
CREATE View population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

-- Global Numbers View for VIZ
CREATE VIEW Globe_num as
Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProj..CovidDeaths
where continent is not null 
Group By date
--order by 1,2



