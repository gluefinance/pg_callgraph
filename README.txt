pg_callgraph
============

BACKGROUND
I have a database centric system consisting of thousands of stored procedures,
where each call to any top-level function makes use of a lot of sub-functions in many layers.

I was about to manually produce call graphs covering all important parts of the system.
I realized this was a huge and boring task. Automation to the rescue.

Simply parsing the functions source code would not be sufficient as I had some functions using EXECUTE.
I also didn't know exactly which functions where top-level functions, and didn't know exactly
which functions were actually being used in production.

Because of this I decided to sample data in run-time to get a real-life picture of the system.
Any functions not being called in productions are not that important to include in the documentation anyway.

DESCRIPTION
Generates call graphs of function calls within a transaction in run-time.
The call graphs are written the first time they are seen in a session to the log.
The format of the log entry is a digraph in the GraphViz DOT language of the oids.

IMPLEMENTATION
New structures added to pgstat:
    static List *call_stack
        all parent functions at the current depth in the current transaction
    static HTAB *call_graph
        all unique pair of function calls so far in the current transaction
    static HTAB *seen_call_graphs
        all unique call graphs seen in the current session to only log once per call graph
    typedef struct PgStat_CallGraphEdge
        contains caller_oid and called_oid

In pgstat_init_function_usage(), each call to a function will add the caller->called oid pair unless already set in the hash.
When pgstat_end_function_usage() is called, the current function oid is removed from the List of parent oids.
In AtEOXact_PgStat(), called upon commit/rollback, the call graph is sorted and written to the log unless already seen in the session.
The variables are resetted in pgstat_clear_snapshot().

This functionality is probably something one would like to enable only temporarily in the production environment.
A new configuration parameter would therefore be good, just like track_functions. Perhaps track_callgraphs?

Instead of writing the call graphs to the postgres log, it would ne more useful to let the statistics collector keep track of the call graphs, to allow easier access than having to parse through the log file.
Perhaps the call graph would be represented as an oid[] array, and be the primary key (or unique) in some new statistics table,
with any interesting columns, perhaps number of calls or any of the data provided by pg_stat_user_functions and pg_stat_user_tables.

EXAMPLE
example_functions.sql contains the functions a(), ab(), ac(), aca(), acb().
I executed the functions a() and ac() and got this in my log file:
2012-01-09 19:08:30.983 CET,"joel","test",28461,"[local]",4f0b2d18.6f2d,1,"SELECT",2012-01-09 19:08:24 CET,3/0,0,LOG,00000,"digraph {37615->37616;37615->37617;37617->37618;37617->37619}",,,,,,"select a();",,,"psql"
2012-01-09 19:08:39.837 CET,"joel","test",28461,"[local]",4f0b2d18.6f2d,2,"SELECT",2012-01-09 19:08:24 CET,3/0,0,LOG,00000,"digraph {37617->37618;37617->37619}",,,,,,"select ac();",,,"psql"

The perl script pg_callgraph.pl replaces the oids with actual function names before generating the call graphs using GraphVIz:
digraph {a->ab;a->ac;ac->aca;ac->acb}
digraph {ac->aca;ac->acb}

The GraphVIz dot command is then used to generate nice call graphs in PNG.

I've also added two real-life examples of quite complex call graphs:
    6edd2b9b520ff2428c461fad43f29131a6c6604f.png
    607e272a35cf2ac8579173f97147a32de9784877.png
