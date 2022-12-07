# Jupyterlab使用新的tqdm进度条

conda install -c conda-forge nodejs
需要安装labextension（这一步需要nodejs>=10），
再安装ipywidgets
conda install -n base -c conda-forge jupyterlab_widgets
conda install -n py36 -c conda-forge ipywidgets
https://ipywidgets.readthedocs.io/en/stable/user_install.html
在侧边栏开启labextension  
tqdm设置from tqdm.auto import trange, tqdm
之后使用就是新的进度条

