/*
Today's Topic: Portfolio Projects 1
*/


Select *
From PortfolioProject1..COVIDDEATHSa
where continent!=''
Order by 3,4


Select *
From PortfolioProject1..COVIDDEATHSa
where continent is not null
Order by 3,4


--Select *
--From PortfolioProject1..COVIDVACCINATIONSa
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..COVIDDEATHSa
where continent!=''
Order By 1,2


--looking at Total Cases Vs Total Deaths 
--This shows the likelihood of dying if one contracts COVID in one's Country

select location, date, total_cases, total_deaths, (try_cast(total_deaths as decimal(12,2))/NULLIF(try_cast(total_cases as int),0))*100 as DeathPercent
From PortfolioProject1..COVIDDEATHSa
where continent!=''
Order By 1,2

select location, date, total_cases, total_deaths, (try_cast(total_deaths as decimal(12,2))/NULLIF(try_cast(total_cases as int),0))*100 as DeathPercent
From PortfolioProject1..COVIDDEATHSa
where location like '%states%'
and continent!=''
Order By 1,2


--Looking at total_cases Vs population
--shows what percentage of population got COVID

select location, date, population, total_cases,  (try_cast(total_cases as decimal(12,2))/NULLIF(try_cast(population as int),0))*100 as PercentPopulationInfected
From PortfolioProject1..COVIDDEATHSa
--where location like '%states%'
where continent!=''
Order By 1,2


--looking at Countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount,  Max(try_cast(total_cases as decimal(12,2))/NULLIF(try_cast(population as int),0))*100 as PercentPopulationInfected
From PortfolioProject1..COVIDDEATHSa
--where location like '%states%'
where continent!=''
Group By location, population
Order By PercentPopulationInfected desc


--Showing Countries with Highest Death Count per population

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..COVIDDEATHSa
--where location like '%states%'
where continent!=''
Group By location
Order By TotalDeathCount desc

--BREAKING DOWN BY CONTINENTS

--Continents with the highest death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..COVIDDEATHSa
--where location like '%states%'
where continent!=''
Group By continent
Order By TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases as float)) as TotalNewCases, SUM(CAST(new_deaths as float)) as TotalNewDeaths, (SUM(CAST(New_deaths as float)) / NULLIF(SUM(CAST(New_Cases as float)), 0)) * 100 AS DeathPercentage
FROM PortfolioProject1..COVIDDEATHSa
WHERE continent!= ''
GROUP BY date
ORDER BY 1, 2


Select *
FROM PortfolioProject1..COVIDDEATHSa dea
Join PortfolioProject1..COVIDVACCINATIONSa vac
	ON dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date )
FROM PortfolioProject1..COVIDDEATHSa dea
Join PortfolioProject1..COVIDVACCINATIONSa vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent!=''
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject1..COVIDDEATHSa dea
Join PortfolioProject1..COVIDVACCINATIONSa vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent!=''
Order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..COVIDDEATHSa dea
Join PortfolioProject1..COVIDVACCINATIONSa vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent!='' 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

-- Drop the existing temporary table if it exists
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated3333', 'U') IS NOT NULL
BEGIN
DROP TABLE #PercentPopulationVaccinated3333;
END;

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated3333
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Rest of the code stays the same
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT
		dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(TRY_CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject1..COVIDDEATHSa dea
    JOIN PortfolioProject1..COVIDVACCINATIONSa vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent != ''
AND ISNUMERIC(vac.new_vaccinations) = 1
)

INSERT INTO #PercentPopulationVaccinated3333
SELECT Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated
FROM PopvsVac;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated3333
FROM #PercentPopulationVaccinated3333;



-- Creating View to store data for visualizations later


-- Drop the existing table if it exists
IF OBJECT_ID('PortfolioProject1..PercentPopulationVaccinated3333', 'U') IS NOT NULL
BEGIN
DROP TABLE PercentPopulationVaccinated3333;
END;

-- Create the physical table
CREATE TABLE PercentPopulationVaccinated3333
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert data into the table
INSERT INTO PercentPopulationVaccinated3333
SELECT
dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(TRY_CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject1..COVIDDEATHSa dea
JOIN PortfolioProject1..COVIDVACCINATIONSa vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
AND ISNUMERIC(vac.new_vaccinations) = 1;

-- Select data from the table
SELECT *
FROM PercentPopulationVaccinated3333;







-- Creating View to store data for visualizations later
-- Create the view
CREATE VIEW VaccinationDataView1 AS
SELECT *
FROM PercentPopulationVaccinated3333;




create view PercentPopulationVaccinated3333 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
FROM PortfolioProject1..COVIDDEATHSa dea
JOIN PortfolioProject1..COVIDVACCINATIONSa vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent!= ''
--Order by 2,3


CREATE VIEW PercentPopulationVaccinated1 AS
SELECT
dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
--   , (Rollingpeoplevaccinated/population)*100   -- Uncomment if you need this column, but make sure it has a unique name
FROM PortfolioProject1..COVIDDEATHSa dea
JOIN PortfolioProject1..COVIDVACCINATIONSa vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
--Order by 2,3


Select *
from PercentPopulationVaccinated1