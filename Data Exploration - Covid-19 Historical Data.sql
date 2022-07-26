-- Adding primary keys to tables.
ALTER TABLE `covidportfolioproject`.`covid_deaths` 
CHANGE COLUMN `index` `index` BIGINT NOT NULL, ADD PRIMARY KEY (`index`);

ALTER TABLE `covidportfolioproject`.`covid_vaccinations` 
CHANGE COLUMN `index` `index` BIGINT NOT NULL, ADD PRIMARY KEY (`index`);

------------------------------------------------------------------------------------------------------------------

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your contry
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covidportfolioproject.covid_deaths
WHERE location like '%norway%'
ORDER  BY 1,2;


-- Looking at the total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM covidportfolioproject.covid_deaths
WHERE location like '%norway%'
ORDER  BY 1,2;


-- Looking at contries with highest infectionrate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM covidportfolioproject.covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing the contries with the highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covidportfolioproject.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

------------------------------------------------------------------------------------------------------------------

-- Isolating by continent
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covidportfolioproject.covid_deaths
WHERE continent is null 
    AND location NOT Like '%international%'
	AND location NOT Like "%income%"
    AND location NOT Like '%Union%'
    AND location NOT Like '%world%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Global numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covidportfolioproject.covid_deaths
WHERE continent is not null
GROUP BY date
ORDER  BY 1,2;

-- Now just the sums
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covidportfolioproject.covid_deaths
WHERE continent is not null
ORDER  BY 1,2;

------------------------------------------------------------------------------------------------------------------

-- Looking at total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CumulativeVaccinations
FROM covidportfolioproject.covid_deaths cd
JOIN covidportfolioproject.covid_vaccinations cv
	ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- Using the CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccinations)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CumulativeVaccinations
FROM covidportfolioproject.covid_deaths cd
JOIN covidportfolioproject.covid_vaccinations cv
	ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (CumulativeVaccinations/population)*100
FROM PopvsVac;
   
    
-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS CumulativeVaccinations
FROM covidportfolioproject.covid_deaths cd
JOIN covidportfolioproject.covid_vaccinations cv
	ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

------------------------------------------------------------------------------------------------------------------