/*

.synopsis
Find blockers and take a snapshot of current processes running on SQL Server. Hand crafted by Jason McGinty and is AI free code.

.license
The MIT License

.script
runningProcess.sql

.type
Ad-hoc script

.author
Jason McGinty

.create date
2024-Aug-07

.last modify date
2024-Aug-07

.github or gitlab location
https://github.com/JasonMcGinty/SQL-TSQL/blob/primary/runningProcess.sql

.support tickets
not applicable

*/

-- get blocks.
-- find lead blocker
select 
	[der1].[session_id]
    ,[der1].[blocking_session_id] as [blockingLeaders]
from 
	[sys].[dm_exec_requests] [der1]
where 
	[der1].[blocking_session_id] in
	(
	select
		[der2].[session_id]
	from 
		[sys].[dm_exec_requests] [der2]
	where 
		[der2].blocking_session_id = 0
	)

-- get process information.
select
	[der].[session_id]
	,[der].[blocking_session_id]
	,[dec].[connect_time]
	,[der].[start_time]
	,[der].[status]
	,[der].[command]
	,[der].[wait_type]
	,[der].[last_wait_type]
	,[der].[percent_complete]
	,[der].[estimated_completion_time]
	,[der].[request_id]
	,db_name([des].[database_id]) as [database_name]
	,[des].[login_name]
	,[des].[status]
	,[des].[cpu_time]
	,[des].[memory_usage]
	,[des].[reads]
	,[des].[logical_reads]
	,[dec].[num_reads]
	,[dec].[last_read]
	,[des].[writes]
	,[dec].[num_writes]
	,[dec].[last_write]
	,[des].[endpoint_id]
	,[dec].[net_transport]
	,[dec].[protocol_type]
	,[dec].[encrypt_option]
	,[dec].[auth_scheme]
	,[dec].[client_net_address]
	,[des].[program_name]
	,[des].[host_process_id]
	,[des].[client_version]
	,[deqp].[query_plan]
	,[dest].[text]
from
	[sys].dm_exec_requests [der] 
	inner join [sys].[dm_exec_sessions] [des] on [der].[session_id] = [des].[session_id]
	left join [sys].[dm_exec_connections] [dec] on [der].[session_id] = [dec].[session_id]
	cross apply [sys].[dm_exec_query_plan] ([der].[plan_handle]) [deqp]
	cross apply sys.dm_exec_sql_text ([der].[sql_handle]) [dest]
where 
	[des].[is_user_process] = 1 and
	[der].[session_id] != @@spid
