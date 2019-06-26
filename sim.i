[Mesh]
  type = FileMesh
  file = {subs:mesh_name}
[]


[Variables]
  [./polar_x]
    order = FIRST
    family = LAGRANGE
    block = 'sphere'
  [../]
  [./polar_y]
    order = FIRST
    family = LAGRANGE
    block = 'sphere'
  [../]
  [./polar_z]
    order = FIRST
    family = LAGRANGE
    block = 'sphere'
  [../]
  
  [./disp_x]
    order = FIRST
    family = LAGRANGE
    #block = 'sphere'
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
    #block = 'sphere'
  [../]
  [./disp_z]
    order = FIRST
    family = LAGRANGE
    #block = 'sphere'
  [../]

  [./potential_int]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  active = {subs:active_ics}
  
  #RANDOM CONDITIONS FOR FIRST ITERATION
  [./ic_polar_x_ferro_random]
    type = RandomIC
    min = {subs:polar_x_value_min}
    max = {subs:polar_x_value_max}
    variable = polar_x
    block = 'sphere'
  [../]
  [./ic_polar_y_ferro_random]
    type = RandomIC
    min = {subs:polar_y_value_min}
    max = {subs:polar_y_value_max}
    variable = polar_y
    block = 'sphere'
  [../]
  [./ic_polar_z_ferro_random]
    type = RandomIC
    min = {subs:polar_z_value_min}
    max = {subs:polar_z_value_max}
    variable = polar_z
    block = 'sphere'
  [../]
  
    #VORTEX
  [./ic_polar_x_vortex]
    type = FunctionIC
    function = vortex_x_func
    variable = polar_x
    block = 'sphere'
  [../]
  [./ic_polar_y_vortex]
    type = FunctionIC
    function = vortex_y_func
    variable = polar_y
    block = 'sphere'
  [../]
  [./ic_polar_z_vortex]
    type = FunctionIC
    function = vortex_z_func
    variable = polar_z
    block = 'sphere'
  [../]
  
  [./pxic]
      type = FunctionIC
      variable = polar_x
      function = pxf
  [../]
  [./pyic]
    type = FunctionIC
    variable = polar_y
    function = pyf
  [../]
  [./pzic]
    type = FunctionIC
    variable = polar_z
    function = pzf
  [../]

  
  [./ppic]
    type = FunctionIC
    variable = potential_int
    function = pps
  [../]
 
  [./dxic]
    type = FunctionIC
    variable = disp_x
    function = disp_x_func
  [../]
  [./dyic]
    type = FunctionIC
    variable = disp_y
    function = disp_y_func
  [../]
  [./dzic]
    type = FunctionIC
    variable = disp_z
    function = disp_z_func
  [../]
 
  [./pz_dom_ic]
    type = FunctionIC
    variable = polar_z
    block = 'sphere'
    function = polar_func
  [../]
[]

[Materials]
  [./eigen_strain_zz] 
   type = ComputeEigenstrain
   block = 'sphere'
  # eigen_base = 'exx exy exz eyx eyy eyz ezx ezy ezz'
   eigen_base = '0 0 0 0 0 0 0 0 0'
   eigenstrain_name = eigenstrain
 [../]
  [./elasticity_tensor_1]
    type = ComputeElasticityTensor
    C_ijkl = {subs:C_ijkl}
   block = 'sphere'
    eigenstrain_name = eigenstrain
  [../]
  [./strain_1]
    type = ComputeSmallStrain
    eigenstrain_names = eigenstrain
    displacements = 'disp_x disp_y disp_z'
   block = 'sphere'
  [../]
  [./stress_1]
    type = ComputeLinearElasticStress
   block = 'sphere'
  [../]
  [./slab_ferroelectric]
    type = ComputeElectrostrictiveTensor
   block = 'sphere'
    C_ijkl = {subs:C_ijkl}
    Q_mnkl = {subs:Q_mnkl}
  [../]
  
  [./elasticity_tensor_2]
    type = ComputeElasticityTensor
    C_ijkl = '1 1 1 1 1 1 1 1 1'
    fill_method = symmetric9
    block = 'cube'
  [../]
  [./strain_2]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
    block = 'cube'
  [../]
  [./stress_2]
    type = ComputeLinearElasticStress
    block = 'cube'
  [../]

[]

[Functions]
  active = {subs:active_funcs}
  
  [./pxf]
    type = SolutionFunction
    solution = soln
    from_variable = polar_x
  [../]
  [./pyf]
    type = SolutionFunction
    solution = soln
    from_variable = polar_y
  [../]
  [./pzf]
    type = SolutionFunction
    solution = soln
    from_variable = polar_z
  [../]
  
  [./disp_x_func]
    type = SolutionFunction
    solution = soln
    from_variable = disp_x
  [../]
  [./disp_y_func]
    type = SolutionFunction
    solution = soln
    from_variable = disp_y
  [../]
  [./disp_z_func]
    type = SolutionFunction
    solution = soln
    from_variable = disp_z
  [../]

  
  [./pps]
    type = SolutionFunction
    solution = soln
    from_variable = potential_int
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y disp_z'
  [../]

  #FERROELECTRIC BLOCK
  [./bed_x_ferro]
    type = BulkEnergyDerivativeSixth
    block = 'sphere'
    variable = polar_x
    polar_x = polar_x
    polar_y = polar_y
    polar_z = polar_z
    alpha1 = {subs:alpha1}
    alpha11 = {subs:alpha11}
    alpha12 = {subs:alpha12}
    alpha111 = {subs:alpha111}
    alpha112 = {subs:alpha112}
    alpha123 = {subs:alpha123}
    component = 0
  [../]
  [./bed_y_ferro]
    type = BulkEnergyDerivativeSixth
    block = 'sphere'
    variable = polar_y
    polar_x = polar_x
    polar_y = polar_y
    polar_z = polar_z
    alpha1 = {subs:alpha1}
    alpha11 = {subs:alpha11}
    alpha12 = {subs:alpha12}
    alpha111 = {subs:alpha111}
    alpha112 = {subs:alpha112}
    alpha123 = {subs:alpha123}
    component = 1
  [../]
  [./bed_z_ferro]
    type = BulkEnergyDerivativeSixth
    block = 'sphere'
    variable = polar_z
    polar_x = polar_x
    polar_y = polar_y
    polar_z = polar_z
    alpha1 = {subs:alpha1}
    alpha11 = {subs:alpha11}
    alpha12 = {subs:alpha12}
    alpha111 = {subs:alpha111}
    alpha112 = {subs:alpha112}
    alpha123 = {subs:alpha123}
    component = 2
  [../]
  
[./ferroelectriccouplingp_xx]
   type = FerroelectricCouplingP
   variable = polar_x
   disp_x = disp_x
   disp_y = disp_y
   disp_z = disp_z
   polar_x = polar_x
   polar_y = polar_y
   polar_z = polar_z
   component = 0
   block = 'sphere'
 [../]
 [./ferroelectriccouplingp_yy]
   type = FerroelectricCouplingP
   variable = polar_y
   disp_x = disp_x
   disp_y = disp_y
   disp_z = disp_z
   polar_x = polar_x
   polar_y = polar_y
   polar_z = polar_z
   component = 1
   block = 'sphere'
 [../]
 [./ferroelectriccouplingp_zz]
   type = FerroelectricCouplingP
   variable = polar_z
   disp_x = disp_x
   disp_y = disp_y
   disp_z = disp_z
   polar_x = polar_x
   polar_y = polar_y
   polar_z = polar_z
   component = 2
   block = 'sphere'
 [../]

[./ferroelectriccouplingp_xx1]
   type = FerroelectricCouplingX
   variable = disp_x
   disp_x = disp_x
   disp_y = disp_y
   disp_z = disp_z
   polar_x = polar_x
   polar_y = polar_y
   polar_z = polar_z
   component = 0
   block = 'sphere'
 [../]
 [./ferroelectriccouplingp_yy1]
   type = FerroelectricCouplingX
   variable = disp_y
   disp_x = disp_x
   disp_y = disp_y
   disp_z = disp_z
   polar_x = polar_x
   polar_y = polar_y
   polar_z = polar_z
   component = 1
   block = 'sphere'
 [../]
 [./ferroelectriccouplingp_zz1]
   type = FerroelectricCouplingX
   variable = disp_z
   disp_x = disp_x
   disp_y = disp_y
   disp_z = disp_z
   polar_x = polar_x
   polar_y = polar_y
   polar_z = polar_z
   component = 2
   block = 'sphere'
 [../]

  [./polar_x_electric_E_ferro]
     type = PolarElectricEStrong
       block = 'sphere'
       polar_x = polar_x
       polar_y = polar_y
       polar_z = polar_z
       len_scale = {subs:lscale}
       variable = potential_int
  [../]
  [./FE_E_int_ferro]
       type = Electrostatics
       block = 'sphere'
       variable = potential_int
       permittivity = {subs:permittivity_electrostatic_ferro}
       len_scale = {subs:lscale}
  [../]

  [./polar_electric_px_ferro]
     type = PolarElectricPStrong
       block = 'sphere'
       variable = polar_x
       len_scale = {subs:lscale}
       potential_E_int = potential_int
       component = 0
  [../]
  [./polar_electric_py_ferro]
     type = PolarElectricPStrong
       block = 'sphere'
       variable = polar_y
       len_scale = {subs:lscale}
       potential_E_int = potential_int
       component = 1
  [../]
  [./polar_electric_pz_ferro]
     type = PolarElectricPStrong
       block = 'sphere'
       variable = polar_z
       len_scale = {subs:lscale}
       potential_E_int = potential_int
       component = 2
  [../]

  [./walled_x_ferro]
    type = WallEnergyDerivative
    block = 'sphere'
    variable = polar_x
    polar_x = polar_x
    polar_y = polar_y
    polar_z = polar_z
    len_scale = {subs:lscale}
    G110 = {subs:G110}
    G11_G110 = {subs:G11_G110}
    G12_G110 = {subs:G12_G110}
    G44_G110 = {subs:G44_G110}
    G44P_G110 = {subs:G44P_G110}
    component = 0
  [../]
  [./walled_y_ferro]
    type = WallEnergyDerivative
    block = 'sphere'
    variable = polar_y
    polar_x = polar_x
    polar_y = polar_y
    polar_z = polar_z
    len_scale = {subs:lscale}
    G110 = {subs:G110}
    G11_G110 = {subs:G11_G110}
    G12_G110 = {subs:G12_G110}
    G44_G110 = {subs:G44_G110}
    G44P_G110 = {subs:G44P_G110}
    component = 1
  [../]
  [./walled_z_ferro]
    type = WallEnergyDerivative
    block = 'sphere'
    variable = polar_z
    polar_x = polar_x
    polar_y = polar_y
    polar_z = polar_z
    len_scale = {subs:lscale}
    G110 = {subs:G110}
    G11_G110 = {subs:G11_G110}
    G12_G110 = {subs:G12_G110}
    G44_G110 = {subs:G44_G110}
    G44P_G110 = {subs:G44P_G110}
    component = 2
  [../]

  [./polar_x_time_ferro]
     type = TimeDerivativeScaled
     block = 'sphere'
     variable = polar_x
     time_scale = {subs:time_scale}
  [../]
  [./polar_y_time_ferro]
     type = TimeDerivativeScaled
     block = 'sphere'
     variable = polar_y
     time_scale = {subs:time_scale}
  [../]
  [./polar_z_time_ferro]
     type = TimeDerivativeScaled
       block = 'sphere'
       variable = polar_z
       time_scale = {subs:time_scale}
  [../]
  
  [./depol_z_ferro]
      type = DepolEnergy
      block = 'sphere'
      permitivitty = {subs:permitivitty_depol_ferro}
      lambda = {subs:lmbd}
      len_scale = {subs:lscale}
      variable = polar_z
      avePz = Polar_z_ferro_avg_element
      polar_z = polar_z
  [../]
  
  #PARAELECTRIC BLOCK
  
  [./FE_E_int_para]
       type = Electrostatics
       block =  'cube'
       variable = potential_int
       permittivity = {subs:permittivity_electrostatic_para}
       len_scale = {subs:lscale}
  [../]

[]

[BCs]
   [./top_phi]
      type = DirichletBC
      variable = potential_int
      value = {subs:up_pot}
      boundary = 'top sphere_top'
   [../]
   [./bottom_phi]
      type = DirichletBC
      variable = potential_int
      value = {subs:bottom_pot}
      boundary = 'bottom sphere_bottom'
   [../]   
   
#  [./disp_x_bottom_top]
#    type = DirichletBC
#    variable = disp_x
#    boundary = 'sphere_surface'
#    value = 0
#  [../]
#  [./disp_y_bottom_top]
#    type = DirichletBC
#    variable = disp_y
#    boundary = 'sphere_surface'
#    value = 0
#  [../]
#  [./disp_z_bottom_top]
#    type = DirichletBC
#    variable = disp_z
#    boundary = 'sphere_surface'
#    value = 0
#  [../]

[]

[Postprocessors]
   [./dt]
     type = TimestepSize
   [../]

  
  [./Fbulk]
      type = BulkEnergy
      block = 'sphere'
      polar_x = polar_x
      polar_y = polar_y
      polar_z = polar_z
      alpha1 = {subs:alpha1}
      alpha11 = {subs:alpha11}
      alpha12 = {subs:alpha12}
      alpha111 = {subs:alpha111}
      alpha112 = {subs:alpha112}
      alpha123 = {subs:alpha123}
      execute_on = 'initial timestep_end final'
   [../]
   [./Fwall]
      type = WallEnergy
      polar_x = polar_x
      polar_y = polar_y
      polar_z = polar_z
      G110 = {subs:G110}
      G11_G110 = {subs:G11_G110}
      G12_G110 = {subs:G12_G110}
      G44_G110 = {subs:G44_G110}
      G44P_G110 = {subs:G44P_G110}
      len_scale = {subs:lscale}
      block = 'sphere'
      execute_on = 'initial timestep_end final'
    [../]
    [./Felec]
      type = ElectrostaticEnergy
      block = 'sphere'
      polar_x = polar_x
      polar_y = polar_y
      polar_z = polar_z
      potential_E_int = potential_int
      len_scale = {subs:lscale}
      execute_on = 'initial timestep_end final'
    [../]
    [./Felastic]
      type = ElasticEnergy
      C_ijkl = {subs:C_ijkl}
      execute_on = 'initial timestep_end final'
      block = 'sphere'
    [../]
    [./Fcoupled]
      type = ElectrostrictiveEnergy
      polar_x = polar_x
      polar_y = polar_y
      polar_z = polar_z
      disp_x = disp_x
      disp_y = disp_y
      disp_z = disp_z
      execute_on = 'initial timestep_end final'
      block = 'sphere'
    [../]

    [./Ftotal]
      type = LinearCombinationPostprocessor
      pp_names = 'Fbulk Fwall Felec Felastic Fcoupled'
      pp_coefs = '   1     1     1      1        1   '
      execute_on = 'initial timestep_end final'
    [../]
    [./perc_change]
     type = EnergyRatePostprocessor
     postprocessor = Ftotal
     dt = dt 
     execute_on = 'initial timestep_end final'
   [../]
   
   [./Polar_z_ferro_avg_element]
    type = ElementAverageValue
    block = 'sphere'
    execute_on = 'initial timestep_end final'
    variable = polar_z
   [../]
   
    
[]

[Problem]
  null_space_dimension = 6
[]

[UserObjects]
  active = {subs:active_user_objects}

  [./rigidbodymodes_x]
     type = RigidBodyModes3D
     subspace_name = NullSpace
     subspace_indices = '0 1 2 3 4 5'
     disp_x = disp_x
     disp_y = disp_y
     disp_z = disp_z
     modes = 'trans_x trans_y trans_z rot_x rot_y rot_z'
  [../]
  [./soln]
    type = SolutionUserObject
    mesh = {subs:previous_sim}
    system_variables = 'polar_x polar_y polar_z potential_int disp_x disp_y disp_z'
    timestep = LATEST
    execute_on = initial
 [../]
  
  [./kill]
    type = Terminator
    expression = 'perc_change <= 5.0e-6'
  [../]

[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true   
    petsc_options_iname = '-ksp_type -snes_atol -snes_rtol -ksp_rtol -snes_type  -pc_type  -sub_pc_type  -pc_asm_type'
    petsc_options_value = '  gmres      1e-10      1e-8      1e-5      newtonls       asm       lu           basic   '
  [../]
[]

[Executioner]

  [./TimeStepper]
     type = IterationAdaptiveDT
     dt = 0.01
     growth_factor = 1.414
     cutback_factor =  0.707
  [../]

  type = Transient
  solve_type = 'NEWTON'
  scheme = 'bdf2'
  
  dtmax = 0.6
[]

[Outputs]
  print_linear_residuals = false
  print_perf_log = true
  
  [./out]
    type = Exodus
    execute_on = 'final'
    file_base = {subs:filebase}
    elemental_as_nodal = true
  [../]
  
  [./outcsv]
    type = CSV
    file_base = {subs:filebase}
    execute_on = 'initial timestep_end final'
  [../]
[]
