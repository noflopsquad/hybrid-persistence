Hybrid Persistence
====================

##An ongoing experiment on hybrid persistence

###DB maintenance tasks.
You can write on the console:

```
rake db:schema
```

to create the schema of the relational DB, and

```
rake db:drop
```

to eliminate the data from from both the relational and mongo DBs.