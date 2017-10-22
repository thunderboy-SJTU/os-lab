#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>


// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;
	int i;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING) and never choose an
	// idle environment (env_type == ENV_TYPE_IDLE).  If there are
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
        uint32_t env_id = 0;
        uint32_t next_id = 0;
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
               envs[next_id].env_status == ENV_RUNNABLE){
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
            env_run(curenv);
        
        //challenge prior scheduling
        /*for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
               envs[next_id].env_status == ENV_RUNNABLE && envs[next_id].env_prior > max_prior){
                high_prior_id = next_id;
                max_prior = envs[high_prior_id].env_prior;
           }
        }
        if((max_prior != 0 && (!curenv)) ||(max_prior != 0 && (curenv->env_prior <= max_prior)) || (max_prior != 0 && curenv->env_status != ENV_RUNNING))
           env_run(&envs[high_prior_id]);
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
		cprintf("No more runnable environments!\n");
		while (1)
			monitor(NULL);
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
		panic("CPU %d: No idle environment!", cpunum());
	env_run(idle);
}
