StockWatcher example with ClientBundle active annotation 
========================================================

Why ClientBundle active annotation?
___________________________________
ClientBundle active annotation generates extensions of CssResource and ClientBundle interfaces for you which otherwise you have to create and support manually.

How to use ClientBundle active annotation?
__________________________________________
### Creation of new ClientBundle
@ImageResources("org/eclpise/xtend/gwt/stockwatcher/images")
@CssResource(value="stock", csses="org/eclpise/xtend/gwt/stockwatcher/css/StockWatcher.css")
@ClientBundle("/Users/kosyakov/Documents/workspaces/vaadin/xtend-gwt-clientbundle/stockwatcher/src/")
interface StockResources {
}

@ClientBundle - this annotation is used to declare the interface as ClientBundle. 
As value of annotation you should type the path to the source folder.

@CssResource - this annotation is used to specify a css resource. 
As value you should type the alias of resource later you will use it to access this resource.
The attribute "csses" is an array of paths to css resources.

@ImageResource – this annotation is used to specify image resources.
As value you should type the path to the directory with images. All images from the directory will be added as resources.

### Access to resources
val stockResource = StockResources.Util.get
val image = new Image(STOCK_RESOURCES.googlecodePng)
val className = STOCK_RESOURCES.stock.watchListNumericColumn

Xtend adds Util class into the interface. Using this class you can get the access to the implementation of the interface.

Where can I get the original implementation of StockWatcher?
____________________________________________________________
https://developers.google.com/web-toolkit/tools/gwtdesigner/tutorials/StockWatcher.zip



