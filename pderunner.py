from copy import deepcopy
from functools import partial
from subprocess import run
from sys import exit

import numpy

from iterscheme import IterationSchemeElement as ISE, IterationScheme as IS, \
                       NoConstants, Constants, named_parameter, namedtuple_adapter
from utils import prepare_config


def _compute_substitutions(subs_history, v):  # v for variables

    if v.phase not in 'ivh':
        print("Wrong phase - {}!".format(phase))
        exit(1)

    subs = {}

    subs['alpha1']   =  2.3305 * (v.t-364.4798) * 10**(-4)
    subs['alpha11']  =  0.4382
    subs['alpha12']  =  0.0743
    subs['alpha111'] =  0.2713
    subs['alpha112'] =  1.2130
    subs['alpha123'] = -5.6895 

    subs['G110']      = 0.173
    subs['G11_G110']  = 1.6
    subs['G12_G110']  = 0
    subs['G44_G110']  = 0.8
    subs['G44P_G110'] = 0.8

    Q11 =  0.0726
    Q12 = -0.0271
    Q44 =  0.0315 / 2.0
    subs['Q_mnkl'] = f"'{Q11} {Q12} {Q12} {Q11} {Q12} {Q11} {Q44} {Q44} {Q44}'"

    c11 = 168.0912
    c12 = 82.6211
    c44 = 40.6504
    subs['C_ijkl'] = f"'{c11} {c12} {c12} {c11} {c12} {c11} {c44} {c44} {c44}'"

    subs['eps_0'] = 8.85 * 10**(-3)
    subs['eps_i'] = 10.0
    subs['eps_p'] = 10.0
    subs['permittivity_electrostatic_ferro'] = subs['eps_0'] * subs['eps_i']
    subs['permittivity_electrostatic_para'] = subs['eps_0'] * subs['eps_p']

    subs['permitivitty_depol_ferro'] = 0.00885
    subs['permitivitty_depol_para']  = 0.00885
    
    subs['lmbd'] = 0.0

    subs['um'] = v.um
    
    subs['up_pot'] = -v.upot/2.0
    subs['bottom_pot'] = v.upot/2.0

    subs['polar_x_value_min'], subs['polar_x_value_max'], \
    subs['polar_y_value_min'], subs['polar_y_value_max'], \
    subs['polar_z_value_min'], subs['polar_z_value_max'] = {
        'v' : (-1e-5, 1e-5, -1e-5, 1e-5, -1e-5, 1e-5),
        'h' : (-1e-5, 1e-5, -1e-5, 1e-5, -1e-5, 1e-5),
        'i' : (-1e-5, 1e-5, -1e-5, 1e-5, -1e-5, 1e-5),
    }[v.phase]
    
    subs['lscale']     = 1.0
    subs['time_scale'] = 1.0
    
    subs['filebase'] = f't_{v.t}_radius_{v.radius}_shift_{v.shift}_upot_{v.upot}'

    subs['mesh_name'] = f'{v.radius}_{v.shift}.msh'
    
    if v.needprev:
        subs['active_ics'] = "'pxic pyic pzic ppic dxic dyic dzic'"
        subs['active_funcs'] = "'pxf pyf pzf pps disp_x_func disp_y_func disp_z_func'" 
        subs['active_user_objects'] = "'soln kill rigidbodymodes_x'"
        subs['previous_sim'] = f"'{subs_history[-1]['previous_sim_name']}.e'"
    else:
        subs['active_ics'] = "'ic_polar_x_ferro_random ic_polar_y_ferro_random ic_polar_z_ferro_random'"
        subs['active_funcs'] = "''" 
        subs['active_user_objects'] = "'kill rigidbodymodes_x'"
        subs['previous_sim'] = 'none_prev_sim.e'
        
    subs_history.append(deepcopy(subs))
    subs_history[-1]['previous_sim_name'] = subs['filebase']
    
    return subs


def main():
    temperature = named_parameter('t', 25.0)
    um = named_parameter('um', -13.0*10**(-3))
    phase = named_parameter('phase', 'i')
    radius = named_parameter('radius', 25)
    upot = named_parameter('upot', numpy.arange(0.0, 10.0, 1.0))
    shift = named_parameter('shift', '10')
    needprev = named_parameter('needprev', [False] + [True]*(len(upot)-1))

    ischeme_elements = Constants(temperature, um, phase, radius, shift) \
                       >> ISE(upot, needprev)
    ischeme = namedtuple_adapter(IS(ischeme_elements))

    subs_history = []
    compute_substitutions = partial(_compute_substitutions, subs_history)

    for values in ischeme:
        subs = compute_substitutions(values)
        sim_config = prepare_config('./sim.i')
        new_config = sim_config(subs)

        sim_filename = f"{subs['filebase']}.i"
        with open(sim_filename, 'w') as simfile:
            simfile.writelines(new_config)

        ferret_run = f'mpiexec -n 28 ferret-opt -i {sim_filename}'
        retcode = run(ferret_run, shell=True)
        #  if retcode != 0:
        #      exit(1)


if __name__ == '__main__':
    main()