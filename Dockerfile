# Chicago Fed Docker Image
# User: jovyan
# This uses the Jupyter DataScience Docker Container with Python, R and Julia

FROM jupyter/datascience-notebook

MAINTAINER Matthew McKay <mamckay@gmail.com>

USER root

#-Add Additional Debian Packages-#
RUN apt-get update
RUN apt-get install -y --no-install-recommends curl ca-certificates dvipng tar
RUN echo "cacert=/etc/ssl/certs/ca-certificates.crt" > ~/.curlrc

#-Upgrade Julia-#
RUN apt-get remove julia -y
#RUN apt-get install julia -y
#RUN apt-add-repository ppa:staticfloat/juliareleases && apt-add-repository ppa:staticfloat/julia-deps && apt-get update && apt-get install julia
RUN wget https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.5-linux-x86_64.tar.gz
RUN tar -xvf julia-0.4.5-linux-x86_64.tar.gz
RUN ln -s ./julia-2ac304dfba/bin/julia /usr/bin/julia

#-Upgrade to Python=3.5-#
RUN conda install --yes \
	python=3.5 \
    'ipywidgets' \
    'pandas' \
    'matplotlib' \
    'scipy' \
    'seaborn' \
    'scikit-learn' \
    'scikit-image' \
    'sympy' \
    'cython' \
    'patsy' \
    'statsmodels' \
    'cloudpickle' \
    'dill' \
    'numba' \
    'bokeh' \
    && conda clean -yt

#-Additional Python Packages-#
RUN pip install quantecon
RUN $CONDA_DIR/envs/python2/bin/pip install quantecon

#-Add Templates-#
#ADD jupyter_notebook_config.py /home/jovyan/.jupyter/
#ADD templates/ /srv/templates/
#RUN chmod a+rX /srv/templates

#-Add Notebooks-#
ADD notebooks/ /home/jovyan/work/

#-Convert notebooks to the current format-#
RUN find /home/. -name '*.ipynb' -exec jupyter nbconvert --to notebook {} --output {} \;
RUN find /home/. -name '*.ipynb' -exec jupyter trust {} \;

USER jovyan

#-Additional Julia Packages-#
RUN echo "cacert=/etc/ssl/certs/ca-certificates.crt" > ~/.curlrc
RUN julia -e 'Pkg.add("PyCall"); Pkg.checkout("PyCall"); Pkg.build("PyCall"); using PyCall'
RUN julia -e 'Pkg.add("IJulia"); using IJulia'
RUN julia -e 'Pkg.add("PyPlot"); Pkg.checkout("PyPlot"); Pkg.build("PyPlot"); using PyPlot' 
RUN julia -e 'Pkg.add("Distributions"); using Distributions'
RUN julia -e 'Pkg.add("KernelEstimator"); using KernelEstimator'
RUN julia -e 'Pkg.update()'