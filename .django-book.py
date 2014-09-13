from django.db.models.loading import get_models
from IPython.html.notebookapp import NotebookApp


get_models()
app = NotebookApp.instance()
app.initialize(argv=["--pylab=inline", "--profile=myserver"])
app.start()
