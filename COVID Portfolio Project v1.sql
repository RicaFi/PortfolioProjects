SELECT*
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT*
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to Store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*
FROM PercentagePopulationVaccinated
