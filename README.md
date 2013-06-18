ClientBundle active annotation 
==============================

Why ClientBundle active annotation?
-----------------------------------
ClientBundle active annotation generates extensions of CssResource and ClientBundle interfaces for you which otherwise you have to create and support manually.

How to use ClientBundle active annotation?
------------------------------------------

### Creation of new ClientBundle
```
@ImageResources("org/eclpise/xtend/gwt/stockwatcher/images")
@CssResource(value="stock", csses="org/eclpise/xtend/gwt/stockwatcher/css/StockWatcher.css")
@ClientBundle("/Users/kosyakov/Documents/workspaces/vaadin/xtend-gwt-clientbundle/stockwatcher/src/")
interface StockResources {
}
```
@ClientBundle - this annotation is used to declare an interface as ClientBundle. 
As value of the annotation you should type the path to the source folder.

@CssResource - this annotation is used to specify a css resource. 
As value you should type the alias of resource. Later you will use it to access this resource.
The attribute "csses" is an array of paths to css resources.

@ImageResource – this annotation is used to specify image resources.
As value you should type the path to the directory with images. All images from the directory will be added as resources.

### Access to resources
```
val stockResources = StockResources.Util.get \\ get the implementation of StockResources client bundle
val image = new Image(stockResources.googlecodePng) \\ create an instance of Image class for googlecode.png picture
val className = stockResources.stock.watchListNumericColumn \\ get an obfuscated name of watchListNumericColumn css class
```
Xtend adds Util class into the interface. Using this class you can get the access to the implementation of the interface.

If you want to compare Xtend version of StockWatcher with Java version you can find the second one here:
https://developers.google.com/web-toolkit/tools/gwtdesigner/tutorials/StockWatcher.zip



