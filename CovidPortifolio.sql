-- Select Data that we are going to be using
SELECT location, date, totalCases, new_cases, totalDeaths, population
FROM dbo.CovidDeaths
ORDER BY  1,2
;
-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
SELECT 
	Location, 
	Date,
	COALESCE(totalCases, 0) AS Total_Cases, 
	COALESCE(totalDeaths, 0) AS Total_Deaths, 
	ROUND(COALESCE((totalDeaths) / NULLIF((totalCases), 0), 0), 5) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE Location = 'Brazil'
ORDER BY  1,2;

-- Looking at Total Cases vs Population
-- Shows  what percentage of population got Covid
SELECT
	Location,
	Date,
	Population,
	COALESCE(totalCases, 0) AS Total_Cases,
	ROUND(COALESCE(totalCases / NULLIF(population, 0), 0), 5) * 100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE Location = 'Brazil'
ORDER BY Location, Date;

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, COALESCE(MAX(totalCases), 0) as HighestInfectionCount, ROUND(COALESCE(MAX((totalCases/population)), 0), 4) * 100 as PercentPopulationInfected
FROM dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population
SELECT 
	Location, 
	COALESCE(MAX(totalDeaths), 0) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Showing Continents with Highest Death count per population (CTE and Location) 
WITH MaxDeathsPerContinent AS (
	SELECT
		Continent,
		MAX(totalDeaths) AS MaxDeathCount
	FROM dbo.CovidDeaths
	WHERE Continent IS NOT NULL
	GROUP BY Continent
)

SELECT
	DISTINCT cd.Continent,
	cd.Location AS LocationWithMaxDeaths,
	mdpc.MaxDeathCount AS TotalDeathsCount	
FROM dbo.CovidDeaths cd
JOIN MaxDeathsPerContinent mdpc ON cd.Continent = mdpc.Continent AND cd.totalDeaths = mdpc.MaxDeathCount
WHERE cd.Continent IS NOT NULL
ORDER BY TotalDeathsCount DESC;

-- Sum of deaths by continent
SELECT 
	Continent,
	SUM(totalDeaths) AS TotalDeaths
FROM dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeaths DESC;

-- Global Numbers
SELECT
	SUM(new_cases) as TotalCases,
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
	ROUND(SUM(CAST(new_deaths AS INT)) / SUM(new_cases), 5) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY TotalCases, TotalDeaths;

-- Lokking at Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinatedPeople) AS 
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
	SUM(CAST(COALESCE(vac.new_vaccinations, 0)AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedPeople
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, 
	 ROUND((TotalVaccinatedPeople * 100.0) / NULLIF(Population, 0), 4) AS VaccinationPercentage
FROM PopvsVac
ORDER BY Location, Date;

-- Creating View to store data for later visualizations
Create View PopvsVac AS
WITH PopvsVacCTE (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinatedPeople) AS 
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
	SUM(CAST(COALESCE(vac.new_vaccinations, 0)AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedPeople
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, 
	 ROUND((TotalVaccinatedPeople * 100.0) / NULLIF(Population, 0), 4) AS VaccinationPercentage
FROM PopvsVacCTE