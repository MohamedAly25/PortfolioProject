SELECT*
FROM PortfolioProject0..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject0..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

Select  location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject0..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- Show likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_deaths/total_cases)*100 
    END AS DeathPercentage
FROM PortfolioProject0..CovidDeaths
WHERE location LIKE '%states%' and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Show What Percentage of Population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_Population_Infection
FROM PortfolioProject0..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Countries With Highst Infection Rate compared Poulation

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Percentage_of_Highest_Population_Infection
FROM PortfolioProject0..CovidDeaths
GROUP BY location, population
ORDER BY Percentage_of_Highest_Population_Infection DESC

-- Showing Countries With Highest Death Count per Poulation

SELECT location, population, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject0..CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC


--Let's break things down by continent

--Showing continents with the highest death count per population
SELECT continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject0..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths
,CASE 
	WHEN SUM(new_cases)= 0 THEN 0
	ELSE SUM(new_deaths)/SUM(new_cases)*100 
END as deathPercrntage
FROM PortfolioProject0..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(BIGINT, Vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location ,Dea.date) AS RollingPeopleVaccinated

--,CASE
--	WHEN Dea.population = 0  THEN 0
--	ELSE RollingPeopleVaccinated/Dea.population
--END

FROM PortfolioProject0..CovidVaccinations Vac join PortfolioProject0..CovidDeaths Dea
	ON Vac.location = Dea.location
	AND Vac.date = Dea.date
WHERE Dea.continent is not null
ORDER BY 2,3


-- Ues CTE 

WITH PopsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(BIGINT, Vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location ,Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject0..CovidVaccinations Vac join PortfolioProject0..CovidDeaths Dea
	ON Vac.location = Dea.location
	AND Vac.date = Dea.date
WHERE Dea.continent is not null
)
SELECT *
,CASE
    WHEN population = 0 THEN 0
    ELSE RollingPeopleVaccinated / CAST(population AS FLOAT) * 100
END AS VaccinationPercentage
FROM PopsVac
ORDER BY 2, 3

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPeoplationVaccinated
CREATE TABLE #PercentPeoplationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPeoplationVaccinated

SELECT  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(BIGINT, Vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location ,Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject0..CovidVaccinations Vac join PortfolioProject0..CovidDeaths Dea
	ON Vac.location = Dea.location
	AND Vac.date = Dea.date
--WHERE Dea.continent is not null
--ORDER BY 2, 3


SELECT *
,CASE
    WHEN population = 0 THEN 0
    ELSE (RollingPeopleVaccinated /population )* 100
END AS VaccinationPercentage
FROM #PercentPeoplationVaccinated
ORDER BY 2, 3


--Creating view to store data for later visualizations

Create view PercentPeoplationVaccinated  as 
SELECT  Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
,SUM(CONVERT(BIGINT, Vac.new_vaccinations))
OVER (PARTITION BY Dea.location Order by Dea.location ,Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject0..CovidVaccinations Vac join PortfolioProject0..CovidDeaths Dea
	ON Vac.location = Dea.location
	AND Vac.date = Dea.date
WHERE Dea.continent is not null
--ORDER BY 2, 3

Select *
from PercentPeoplationVaccinated