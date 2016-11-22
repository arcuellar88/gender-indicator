select 
    ind.indicator_id as INDICATOR_ID,
    il.Indicator_Name as INDICATOR,
	il.Indicator_Short_Def as INDICATOR_DESC,
	il.Gender as GENDER,
	il.Quintile as QUINTILE,
	il.Area as AREA,
	il.Age as AGE,
	il.Education as EDUCATION,
	topic.Topic_Name as TOPIC, 
	sd.DataSet_Name as SOURCE 
from 
[dbo].[Indicator] ind join [dbo].[Topic_Language] topic
on ind.[Topic_ID]=topic.[Topic_ID]
join [dbo].[Source_Dataset]  sd
on ind.Source_Dataset_ID=sd.Source_Dataset_ID
join [dbo].[Indicator_Language] il
on ind.indicator_id=il.[Indicator_ID]
where topic.Language_ID=1 and il.[Language_ID]=1 and il.[Gender] is not null;
