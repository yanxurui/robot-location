# Test nginx location directive by robotframework


## run
ALl options of robot are placed in args.in.
You may need to set `ngx_install_dir` to suit your case in args.in.
If you don't want to stop nginx after test execution you can set `do_post` to False.

```
robot --argumentfile args.in
```

If you just want to run a specifi test
```
robot --argumentfile args.in  --test Exact_Match
```
