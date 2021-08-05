CREATE DATABASE Sample_project

USE Sample_project

Select *
From Sample_project..CovidDeath
Where continent is not null
Order by 3,4

--Select *
--From Sample_project..CovidVaccinations
--Order by 3,4

---Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, Population
From Sample_project..CovidDeath
Order by 1,2

---looking at total vs total deaths
---shows likelyhood of dying of covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Sample_project..CovidDeath
Where location like 'United%'
Order by 1,2

---looking at total cases vs population

Select location, population, Max(total_cases) as highCases,  Max((total_cases/population))*100 as Popinfected
From Sample_project..CovidDeath
--Where location like '%India%'
GROUP BY location, population
Order by Popinfected desc

--showing countries with highest death count

Select location, Max(cast(total_deaths as int)) as totalDeathCount
From Sample_project..CovidDeath
--Where location like '%India%'
Where continent is null
GROUP BY location
order by totalDeathCount desc

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Sample_project..CovidDeath
--Where location like '%India%'
Where continent is not null
--group by date
Order by 1,2

--Joining Tables and looking total population vs vaccinations

Select dea.continent, dea.location,dea.date, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Sample_project..CovidDeath dea
Join Sample_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, Population, New_Vaccination, rollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Sample_project..CovidDeath dea
Join Sample_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*,(rollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

Create Table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
rollingPeopleVaccinated numeric
)
Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Sample_project..CovidDeath dea
Join Sample_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 

Select * ,(rollingPeopleVaccinated/Population)*100
From #percentpopulationvaccinated 


--Creating view to store data later for visualisations

Create View percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Sample_project..CovidDeath dea
Join Sample_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 

select *
From percentpopulationvaccinated

--ICU patients and hospitalised patients vs  total death

Select Location, Date, total_deaths, hosp_patients, icu_patients 
, cast(total_deaths as int)/cast(hosp_patients as int)*100 as DeathPercentage 
, cast(icu_patients as int)/cast(total_deaths as int)*100 as critical_death
From Sample_project..CovidDeath
Where hosp_patients > 0 and icu_patients > 0
--Group by location, date
Order by 1,2


-- hospital admission vs icu admission

Select Location, convert (bigint, population), Cast(total_deaths as int) as death_col, reproduction_rate, (cast(total_deaths as int) / population) *100 as death_rate
--, cast(weekly_hosp_admissions as int)/cast(weekly_icu_admissions as int)*100 as DeathPercentage 
--, (cast(icu_patients as int)/cast(total_deaths as int))*100 as critical_death
From Sample_project..CovidDeath
--Where hosp_patients > 0 and icu_patients > 0
--Group by location,population
Order by 1,2

--no of tests vs population

Select dea.location, dea.population, SUM(cast(vac.new_tests as bigint)) as teste, SUM(cast(vac.new_tests as bigint)) / (dea.population) * 100 as test_rate
From Sample_project..CovidDeath dea	
Join Sample_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where vac.new_tests > 0
group by dea.location, dea.population 
Order by 1


