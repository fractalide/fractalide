pub struct CoreScheduler {
    pub sched: Scheduler,
    pub subnets: HashMap<String, CoreSchedulerSubnet>,
}

impl CoreScheduler {
    pub fn new() -> CoreScheduler {
        CoreScheduler {
            sched: Scheduler::new(),
            subnets: HashMap::new(),
        }
    }
}

pub struct CoreSchedulerSubnet {
    pub nodes: Vec<String>,
    pub ext_in: HashMap<String, (String, String)>,
    pub ext_out: HashMap<String, (String, String)>,
}

impl CoreSchedulerSubnet {
    pub fn new() -> CoreSchedulerSubnet {
        CoreSchedulerSubnet {
            nodes: vec![],
            ext_in: HashMap::new(),
            ext_out: HashMap::new(),
        }
    }
}
