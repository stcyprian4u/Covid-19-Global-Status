show databases; 
create database if not exists portfolioproject1;
show databases;
show create database portfolioproject1;
use portfolioproject1;

---To upload large dataset/file into MySQL workbench using "local infle"--
---first create table with column headers only--

create table coviddeaths
(
iso_code varchar (255),
continent varchar(255),
location varchar(255),
date date,
population double,
total_cases double,
new_cases double,
new_cases_smoothed double,
total_deaths double,
new_deaths double,
new_deaths_smoothed double,
total_cases_per_million double,
new_cases_per_million double,
new_cases_smoothed_per_million double,
total_deaths_per_million double,
new_deaths_per_million double,
new_deaths_smoothed_per_million double,
reproduction_rate double,
icu_patients double,
icu_patients_per_million double,
hosp_patients double,
hosp_patients_per_million double,
weekly_icu_admissions double,
weekly_icu_admissions_per_million double,
weekly_hosp_admissions double,
weekly_hosp_admissions_per_million double
); 

show tables;
desc table coviddeaths;
select * from coviddeaths; 

--Then load dataset with "local infile" into table--
--and ignore first row (Column headers)---

show variables like "local_infile";
set global local_infile = 1;

load data local infile '/Users/DELL/Desktop/CovidDeaths.csv'
into table coviddeaths
fields terminated by ','
ignore 1 rows;

select * from coviddeaths;
select count(*) from coviddeaths;

---To upload 2nd large dataset/file into MySQL using "local infle"--
--First creat 2nd table with column headers only-- 

create table covidvaccinations
(
iso_code varchar (255), 
continent varchar (255), 
location varchar (255), 
date date, 
total_tests double,
new_tests double,
total_tests_per_thousand double,
new_tests_per_thousand double,
new_tests_smoothed double,
new_tests_smoothed_per_thousand double,
positive_rate double,
tests_per_case double,
tests_units double,
total_vaccinations double,
people_vaccinated double, 
people_fully_vaccinated double,
total_boosters double, 
new_vaccinations double, 
new_vaccinations_smoothed double, 
total_vaccinations_per_hundred double, 
people_vaccinated_per_hundred double, 
people_fully_vaccinated_per_hundred double, 
total_boosters_per_hundred double, 
new_vaccinations_smoothed_per_million double, 
new_people_vaccinated_smoothed double, 
new_people_vaccinated_smoothed_per_hundred double, 
stringency_index double, 
population_density double, 
median_age double, 
aged_65_older double, 
aged_70_older double, 
gdp_per_capita double, 
extreme_poverty double,
cardiovasc_death_rate double,
diabetes_prevalence double,
female_smokers double,
male_smokers double,
handwashing_facilities double,
hospital_beds_per_thousand double,
life_expectancy double, 
human_development_index double, 
excess_mortality_cumulative_absolute double,
excess_mortality_cumulative double,
excess_mortality double,
excess_mortality_cumulative_per_million double
); 

show tables;
desc table covidvaccinations;
select * from covidvaccinations; 

--Then load dataset with "local infile" into table--
--and ignore first row (Column headers)---

load data local infile '/Users/DELL/Desktop/CovidVaccinations.csv'
into table covidvaccinations
fields terminated by ','
ignore 1 rows;

select * from covidvaccinations;
select count(*) from covidvaccinations;

---QUERIES
--using the coviddeaths table-- 

---1. Infection Fatality Rate (showing the percentage of persons dieing from covid)

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 3) AS Infection_Fatality_rate
FROM
    coviddeaths
WHERE location NOT IN ('world' , 'High income', 'africa', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
ORDER BY 1 , 2; 

---2. Infection Fatality Rate by location/country

SELECT 
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 3) AS IFR_by_Country
FROM
    coviddeaths
WHERE location LIKE 'united_states'

---3. Total Infection Fatality per location/country (showing the percentage of persons who died from covid per Country)

SELECT 
    location,
    MAX(total_cases) AS Total_Cases,
    MAX(total_deaths) AS Total_Deaths,
    ROUND((MAX(total_deaths) / MAX(total_cases)) * 100, 3) AS IF_per_Country
FROM
    coviddeaths
WHERE location NOT IN ('world' , 'High income', 'africa', 'Upper middle income', 'Europe', 'asia', 'North America', 'south america',
       'Lower middle income', 'european Union')
GROUP BY location
ORDER BY 1 , 2; 


---4. Infection Fatality per country(Top 10) -(showing the top 10 in percent of persons who died from covid by location)

SELECT 
    location,
    MAX(total_cases) AS Total_cases,
    MAX(total_deaths) AS Total_Deaths,
    ROUND((MAX(total_deaths) / MAX(total_cases)) * 100, 3) AS Top10_Infection_Fatality
FROM
    coviddeaths
WHERE location NOT IN ('world' , 'High income', 'africa', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
GROUP BY location
ORDER BY Top10_Infection_Fatality DESC
LIMIT 10; 

---5. Covid Cases per Location (showing percentage of population who contracted covid per Country)

SELECT 
    location,
    population,
    MAX(total_cases) AS Total_Cases,
    ROUND(MAX(total_cases) / population * 100, 3) AS Covid_Cases
FROM
    coviddeaths
WHERE
    location NOT IN ('world' , 'High income', 'africa', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
GROUP BY location , population
ORDER BY Covid_Cases DESC;


---6. Covid Mortality Rate per country (showing percentage of population who died from covid per location)

SELECT 
    location,
    population,
    MAX(total_deaths) AS Total_Deaths,
    ROUND(MAX(total_deaths) / population * 100, 3) AS Mortality_Rate
FROM
    coviddeaths
WHERE location NOT IN ('world' , 'High income', 'africa', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
GROUP BY location , population;

---7. Covid Death Count per country

SELECT 
    location, MAX(total_deaths) AS Death_Count
FROM
    coviddeaths
WHERE location NOT IN ('world' , 'africa', 'High income', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
GROUP BY location
ORDER BY Death_Count DESC; 

Create view Infection_Fatality as
SELECT 
    location,
    MAX(total_cases) AS Total_Cases,
    MAX(total_deaths) AS Total_Deaths,
    ROUND((MAX(total_deaths) / MAX(total_cases)) * 100, 3) AS Infection_Fatality
FROM
    coviddeaths
WHERE location NOT IN ('world' , 'High income', 'africa', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
GROUP BY location
ORDER BY Infection_Fatality DESC; 

---QUERIES
---using the covidvaccinations table--

---8. Count for number of Tests, Vaccinations and fully vaccinated people per country

SELECT 
    location,
    MAX(total_tests) AS Total_Tests,
    MAX(total_vaccinations) AS Total_Vac,
    MAX(people_fully_vaccinated) AS Full_Vac
FROM
    covidvaccinations
WHERE location NOT IN ('world' , 'africa', 'High income', 'Upper middle income', 'Europe', 'asia', 'North America',
        'south america', 'Lower middle income', 'european Union')
GROUP BY location; 

---9. Total vaccination rate per country

SELECT 
    location, date, total_vaccinations
FROM
    covidvaccinations
WHERE location LIKE 'china'; 

---10. Percentage of population fully vaccinated by location/country

SELECT 
    ROUND((MAX(CV.people_fully_vaccinated) / CD.population) * 100, 1) AS Fully_Vac_Pop
FROM
    covidvaccinations AS CV
LEFT JOIN coviddeaths AS CD 
ON CV.iso_code = CD.iso_code
WHERE CV.location LIKE 'united_kingdom'
GROUP BY population; 

---11. Percentage of fully vaccinated people who died from Covid by country

SELECT 
    ROUND((MAX(CD.total_deaths) / MAX(CV.people_fully_vaccinated)) * 100, 2) AS Fully_Vac_But_Died
FROM
    covidvaccinations AS CV
LEFT JOIN coviddeaths AS CD ON CV.location = CD.location
WHERE CV.location LIKE 'united_states' 

---12. Global situation 

SELECT 
    MAX(CD.total_cases) AS Total_Cases,
    MAX(CD.total_deaths) AS Total_Deaths,
    ROUND((MAX(CD.total_deaths) / MAX(CD.total_cases)) * 100, 3) AS Death_Percentage,
    MAX(CV.people_fully_vaccinated) AS Fully_Vaccinated
FROM 
    coviddeaths AS CD
	LEFT JOIN covidvaccinations AS CV 
    ON CD.iso_code = CV.iso_code;

