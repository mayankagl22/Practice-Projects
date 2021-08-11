Select *
From Sample_project.dbo.Nifty50

--All distinct symbols

Select Distinct(Symbol)
From Sample_project.dbo.Nifty50

--Update table with only date

Select Date, Convert(Date, Date) 
From Sample_project.dbo.Nifty50 

Update Sample_project.dbo.Nifty50
Set Date_upd = Convert(Date, Date)

Alter Table Sample_project.dbo.Nifty50
Add date_upd Date

Update Sample_project.dbo.Nifty50
Set Date_upd = Convert(Date, Date)

--Find aveage price of each symbol

Select Symbol, AVG(VWAP) as Price_avgd, MAX(VWAP) as Price_max
From Sample_project.dbo.Nifty50
Where VWAP is not null
Group by Symbol
Order by 1

--Change in Prev clos and High and Low price

Select Distinct(Symbol), date_upd, [Prev Close], High, Low, (High - [Prev Close]) as high_diff, (Low - [Prev Close]) as low_diff
From Sample_project.dbo.Nifty50
--Where high_diff >0
--Group by Symbol
Order by 6 Desc

--Precentage difference between previous close and next day high

With percent_diff (Symbol, date_upd, [Prev Close], High, Low, high_diff, low_diff)
as
(
Select Symbol, date_upd, [Prev Close], High, Low, High - [Prev Close] as high_diff, Low - [Prev Close] as low_diff
From Sample_project.dbo.Nifty50
--Where high_diff >0
--Group by Symbol
--Order by 6 Desc
)
Select * ,high_diff / [Prev Close] *100 as high_perc
From percent_diff
Where high_diff > 0 and [Prev Close] >0
Order by 8 Desc

-- Grouping price and turnover by year and symbol 

Select DATEPART(year, date_upd) as yearly
From Sample_project.dbo.Nifty50

Alter Table Sample_project.dbo.Nifty50
Add Year_on int

Update Sample_project.dbo.Nifty50
Set Year_on = DATEPART(year, date_upd)


Select Symbol, Year_on, AVG(VWAP) as yearly_price, AVG(Turnover) as turnover_avgd
From Sample_project.dbo.Nifty50
--Where high_diff >0
Group by Symbol, Year_on
Order by 1,2

--High delivery volume scrips

Select Symbol,date_upd, [Prev Close], VWAP, Volume, [Deliverable Volume], [Deliverable Volume] / Volume *100 as Delivery_vol
From Sample_project.dbo.Nifty50
order by 6 Desc