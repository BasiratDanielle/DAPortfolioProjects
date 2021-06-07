Select *
From Portfolio_Project..Covid_Deaths
Order by 3,4

--Select *
--From Portfolio_Project..Covid_Vaccinations
--Order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
Order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of death if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percentage_of_deaths
From Portfolio_Project..Covid_Deaths
Where location like '%states%'
Order by 1,2

--looking at total cases vs population
--what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population) * 100 AS percentage_of_cases
From Portfolio_Project..Covid_Deaths
Where location like '%states%'

--looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)) * 100 AS percent_of_pop_infected
From Portfolio_Project..Covid_Deaths
--Where location like '%states%'
Group by Location, population
Order by percent_of_pop_infected desc

--BREAKING THINGS DOWN BY CONTINENT

--showing continents with highest death counts
Select continent, MAX(cast (total_deaths as int)) as total_death_count
From Portfolio_Project..Covid_Deaths
--Where location like '%states%'
Where continent is not null
Group by continent 
Order by total_death_count desc


--global numbers
Select SUM(new_cases) AS TotalCasesGlobal, SUM(cast(new_deaths as int)) AS TotalDeathsGlobal, sum(cast(new_deaths as int))/sum(new_cases) * 100 AS PercentageDeathsGlobal
From Portfolio_Project..Covid_Deaths
--Where location like '%states%'
Where continent is not null
--group by date
Order by 1,2



--total population vs vaccinations
--joining two tables

--	using CTE
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths as dea
Join Portfolio_Project..Covid_Vaccinations as vac
On dea.location = vac.location
And dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac




--temp table example
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths as dea
Join Portfolio_Project..Covid_Vaccinations as vac
On dea.location = vac.location
And dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/population)* 100
From #PercentPopulationVaccinated

--Create view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths as dea
Join Portfolio_Project..Covid_Vaccinations as vac
On dea.location = vac.location
And dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *
From PercentPopulationVaccinated