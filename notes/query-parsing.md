## Query Parsing

When you enter a query into PostgreSQL, it is parsed internally into an abstract syntax tree (AST). That AST is not readily available to you. However, [a C library and a patched version of PostgreSQL](https://github.com/lfittl/libpg_query) will let you get to it. This library is used to power more user-friendly libraries for a number of languages, including [pg-query-parser for Node](https://github.com/zhm/pg-query-parser) and [pg_query for Ruby](https://github.com/lfittl/pg_query).

Of all the libraries I tried, the output from pg_query is the easiest to get at. Here's an example.

```ruby
[2] pry(main)> require 'pg_query'
[4] pry(main)> query = PgQuery.parse("SELECT s.name, COUNT(1) FROM movies m INNER JOIN studios s ON m.studio_id = s.id GROUP BY s.name")
=> #<PgQuery:0x005601196ba1c8
 @query=
  "SELECT s.name, COUNT(1) FROM movies m INNER JOIN studios s ON m.studio_id = s.id GROUP BY s.name",
 @tree=
  [{"SelectStmt"=>
     {"targetList"=>
       [{"ResTarget"=>
          {"val"=>
            {"ColumnRef"=>
              {"fields"=>
                [{"String"=>{"str"=>"s"}},
                 {"String"=>{"str"=>"name"}}],
               "location"=>7}},
           "location"=>7}},
        {"ResTarget"=>
          {"val"=>
            {"FuncCall"=>
              {"funcname"=>[{"String"=>{"str"=>"count"}}],
               "args"=>
                [{"A_Const"=>
                   {"val"=>{"Integer"=>{"ival"=>1}},
                    "location"=>21}}],
               "location"=>15}},
           "location"=>15}}],
      "fromClause"=>
       [{"JoinExpr"=>
          {"jointype"=>0,
           "larg"=>
            {"RangeVar"=>
              {"relname"=>"movies",
               "inhOpt"=>2,
               "relpersistence"=>"p",
               "alias"=>{"Alias"=>{"aliasname"=>"m"}},
               "location"=>29}},
           "rarg"=>
            {"RangeVar"=>
              {"relname"=>"studios",
               "inhOpt"=>2,
               "relpersistence"=>"p",
               "alias"=>{"Alias"=>{"aliasname"=>"s"}},
               "location"=>49}},
           "quals"=>
            {"A_Expr"=>
              {"kind"=>0,
               "name"=>[{"String"=>{"str"=>"="}}],
               "lexpr"=>
                {"ColumnRef"=>
                  {"fields"=>
                    [{"String"=>{"str"=>"m"}},
                     {"String"=>{"str"=>"studio_id"}}],
                   "location"=>62}},
               "rexpr"=>
                {"ColumnRef"=>
                  {"fields"=>
                    [{"String"=>{"str"=>"s"}},
                     {"String"=>{"str"=>"id"}}],
                   "location"=>76}},
               "location"=>74}}}}],
      "groupClause"=>
       [{"ColumnRef"=>
          {"fields"=>
            [{"String"=>{"str"=>"s"}},
             {"String"=>{"str"=>"name"}}],
           "location"=>90}}],
      "op"=>0}}],
 @warnings=[]>
```

You can use this to investigate how PostgreSQL works. For example, PostgreSQL groups similar queries together in reporting. It uses a fingerprinting system that you can see in action:

```ruby
[9] pry(main)> PgQuery.parse("SELECT * FROM movies WHERE id = 1").fingerprint
=> "01d1fab350fc89c585c0646a45f351493f7bba2f33"
[10] pry(main)> PgQuery.parse("SELECT * FROM movies WHERE id = 2").fingerprint
=> "01d1fab350fc89c585c0646a45f351493f7bba2f33"
```