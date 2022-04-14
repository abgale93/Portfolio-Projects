-- Project - Covid 19 Data Exploration 
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

---------------------------------------------------------------------------------------------------------

SELECT *
FROM ProgrammingProject..CovidDeaths
ORDER BY 3,4

-- Selecting the Data to Start With

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProgrammingProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths eg. Canada

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProgrammingProject..CovidDeaths
WHERE location LIKE 'Canada'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking At Total Cases vs. Population eg. Canada (Showing percentage infected with Covid-19)

SELECT Location, date, total_cases, population, (cast(total_cases as decimal)/cast(population as decimal))*100 AS PercentPopulationInfected
FROM ProgrammingProject..CovidDeaths
WHERE location LIKE 'Canada'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as decimal)/cast(population as decimal)))*100 AS PercentPopulationInfected
FROM ProgrammingProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM ProgrammingProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------

-- Breaking Things Down by Continent Now

-- Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM ProgrammingProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers (Grouped by Date)

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as decimal))/SUM(CAST(new_cases AS decimal))*100 AS DeathPercentage
FROM ProgrammingProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers (Total Count as Percentage)

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as decimal))/SUM(CAST
(new_cases AS decimal))*100 AS DeathPercentage
FROM ProgrammingProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Population Vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProgrammingProject..CovidDeaths dea
JOIN ProgrammingProject..CovidVaccinations vac
    ON dea.location = vac.location  
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-----------------------------------------------------------------------------------------------------------------------

-- USE CTE with 'Partition By' in Previous Query

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProgrammingProject..CovidDeaths dea
JOIN ProgrammingProject..CovidVaccinations vac
     ON dea.location = vac.location  
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/CAST(population AS decimal))*100 AS PercentVaccinated
FROM PopvsVac

------------------------------------------------------------------------------------------------------------------------------------------------

-- Using A Temp Table to Perform A Calculation on the Partition By in Previous Query

--DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProgrammingProject..CovidDeaths dea
JOIN ProgrammingProject..CovidVaccinations vac
    ON dea.location = vac.location  
    and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/CAST(population AS decimal))*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated

----------------------------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProgrammingProject..CovidDeaths dea
JOIN ProgrammingProject..CovidVaccinations vac
    ON dea.location = vac.location  
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------