-- Queries used for Tableau Project (with comments)

-- 1. Calculates total COVID-19 cases, total deaths, and death percentage globally (excluding aggregated data like continents)
Select 
    SUM(new_cases) as total_cases, 
    SUM(cast(new_deaths as int)) as total_deaths, 
    SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDB..CovidDeaths
-- Filters out entries without a continent (to exclude summary rows like "World" or "International")
where continent is not null 
-- Results are ordered by the totals (not grouped by date)
order by 1,2


-- 2. Calculates the total number of deaths for each region that is not a continent (like "World", "EU", etc.)
Select 
    location, 
    SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDB..CovidDeaths
-- Filters out continents and aggregated locations to focus on specific regions like countries
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Shows the highest number of total cases and infection percentage per population by location (country-level)
Select 
    Location, 
    Population, 
    MAX(total_cases) as HighestInfectionCount,  
    Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDB..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Similar to Query 3, but includes the date at which the infection count peaked for each country
Select 
    Location, 
    Population,
    date, 
    MAX(total_cases) as HighestInfectionCount,  
    Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDB..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 6. Tracks vaccination progress by calculating a running total of vaccinated people for each country and the corresponding percentage of the population
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
    Select 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        -- Running total of new vaccinations per country
        SUM(CONVERT(int,vac.new_vaccinations)) 
            OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    From CovidDB..CovidDeaths dea
    Join CovidDB..CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    -- Excludes summary rows without a continent
    where dea.continent is not null 
)
-- Calculates vaccination percentage per country per day
Select *, 
       (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. Repetition of Query 4 (could be removed unless intentionally reused)
Select 
    Location, 
    Population,
    date, 
    MAX(total_cases) as HighestInfectionCount,  
    Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDB..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
