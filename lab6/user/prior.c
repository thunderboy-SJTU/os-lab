#include<inc/lib.h>
#include<inc/env.h>

void
umain(int argc, char **argv)
{
    int pid;
    int i;
    struct Env* env;
    if((pid = fork()) != 0){
        sys_env_set_prior(pid,PRIOR_HIGH);
        if((pid = fork())!= 0)
           sys_env_set_prior(pid,PRIOR_LOW);
    }
    sys_yield();
    env = (struct Env*)envs + ENVX(sys_getenvid());
    for(i = 0; i < 3;i++){
       if(env->env_prior == PRIOR_HIGH)
          cprintf("[%08x] HIGH PRIOR %d iteration\n",sys_getenvid(),i);
       if(env->env_prior == PRIOR_MIDD)
          cprintf("[%08x] MIDD PRIOR %d iteration\n",sys_getenvid(),i);
       if(env->env_prior == PRIOR_LOW)
          cprintf("[%08x] LOW PRIOR %d iteration\n",sys_getenvid(),i);
       sys_yield();
    }
}
