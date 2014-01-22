package org.eclipse.xtend.gwt.clientbundle.client

import com.google.gwt.core.client.GWT
import com.google.gwt.dev.util.log.PrintWriterTreeLogger
import com.google.gwt.resources.client.ClientBundle.Source
import com.google.gwt.resources.client.CssResource.ClassName
import com.google.gwt.resources.client.ImageResource
import com.google.gwt.resources.css.DefsCollector
import com.google.gwt.resources.css.ExtractClassNamesVisitor
import com.google.gwt.resources.css.GenerateCssAst
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration

@Target(ElementType.TYPE)
annotation CssResource {
	String value
	String[] csses
}

@Target(ElementType.TYPE)
annotation ImageResources {
	String value
}

@Target(ElementType.TYPE)
@Active(CliendBundleProcessor)
annotation ClientBundle {
}

class CliendBundleProcessor implements RegisterGlobalsParticipant<InterfaceDeclaration>, TransformationParticipant<MutableInterfaceDeclaration> {

	private static final String INSTANCE = 'INSTANCE'

	private static final String[] EXTENSIONS = #["jpeg", "png", "bmp", "wbmp", "gif"]

	override doRegisterGlobals(List<? extends InterfaceDeclaration> annotatedSourceElements,
		RegisterGlobalsContext context) {
		for (InterfaceDeclaration it : annotatedSourceElements) {
			doRegisterGlobals(context)
		}
	}

	def doRegisterGlobals(InterfaceDeclaration it, extension RegisterGlobalsContext context) {
		registerClass(getUtilTypeName)
		for (cssResource : getCssResources) {
			registerInterface(getCssResourceTypeName(cssResource))
		}
	}

	def getCssResourceTypeName(InterfaceDeclaration it, AnnotationReference cssResource) {
		'''«getPackageName».«cssResource.getValue.toFirstUpper»CssResource'''.toString
	}

	def getPackageName(InterfaceDeclaration it) {
		qualifiedName.substring(0, qualifiedName.length - simpleName.length - 1)
	}

	def getUtilTypeName(InterfaceDeclaration it) {
		'''«qualifiedName».Util'''.toString
	}

	override doTransform(List<? extends MutableInterfaceDeclaration> annotatedTargetElements,
		extension TransformationContext context) {
		for (MutableInterfaceDeclaration it : annotatedTargetElements) {
			doTransform(context)
		}
	}

	def doTransform(MutableInterfaceDeclaration it, extension TransformationContext context) {
		extendedInterfaces = extendedInterfaces + #[com.google.gwt.resources.client.ClientBundle.newTypeReference]
		val utilType = findClass(utilTypeName)
		val clientBundleType = newTypeReference
		utilType.addField(INSTANCE,
			[
				static = true
			]).type = clientBundleType

		val clientBundle = findAnnotation(ClientBundle.newTypeReference.type)
		val sourceFolder = compilationUnit.filePath.sourceFolder

		val cssResources = cssResources
		for (cssResource : cssResources) {
			val cssResourceType = findInterface(getCssResourceTypeName(cssResource))
			cssResourceType.doTransform(clientBundle, cssResource, context)

			addMethod(cssResource.value,
				[
					addAnnotation(Source.newTypeReference.type) => [
						setStringValue("value", cssResource.csses)
					]
				]).returnType = cssResourceType.newTypeReference
		}

		val imageResource = findAnnotation(ImageResources.newTypeReference.type)
		if (imageResource != null) {
			val imageResourceValue = imageResource.value
			sourceFolder.append(imageResourceValue).children.forEach [ children |
				if (EXTENSIONS.map[format|children.fileExtension == format].reduce[sf1, sf2|(sf1 || sf2)]) {
					addMethod(children.lastSegment.methodName) [
						returnType = ImageResource.newTypeReference
						addAnnotation(Source.newTypeReference.type) => [
							setStringValue("value",
								'''«imageResourceValue»«IF !imageResourceValue.endsWith('/')»/«ENDIF»«children.lastSegment»''')
						]
					]
				}
			]
		}

		val getMethodBody = '''
		if («INSTANCE» == null) {
			«INSTANCE» = «GWT.name».create(«clientBundleType.simpleName».class);
			«FOR cssResource : cssResources»
				«INSTANCE».«cssResource.value»().ensureInjected();
			«ENDFOR»
		}
		return «INSTANCE»;'''
		utilType.addMethod('get',
			[
				static = true
				body = [getMethodBody]
			]).returnType = clientBundleType
		
		clientBundle.remove
		imageResource?.remove
		cssResources.forEach[remove]
	}

	def doTransform(MutableInterfaceDeclaration it, AnnotationReference clientBundle, AnnotationReference cssResouce,
		extension TransformationContext context) {
		extendedInterfaces = extendedInterfaces + #[com.google.gwt.resources.client.CssResource.newTypeReference]
		val sourceFolder = compilationUnit.filePath.sourceFolder
		val cssStylesheet = GenerateCssAst.exec(new PrintWriterTreeLogger,
			cssResouce.csses.map [
				sourceFolder.append(it)
			].filter [
				if (!exists) {
					cssResouce.addError("File does not exist: " + it)
					return false
				}
				true
			].map [
				toURI.toURL
			]);
		val defsCollector = new DefsCollector();
		defsCollector.accept(cssStylesheet);
		defsCollector.defs.forEach [ ^def |
			addMethod(def) [
				returnType = String.newTypeReference
			]
		]

		ExtractClassNamesVisitor.exec(cssStylesheet).forEach [ className |
			val methodName = className.methodName
			addMethod(it, methodName, className, context)
		]
	}

	def MutableMethodDeclaration addMethod(MutableInterfaceDeclaration it, String methodName, String className,
		extension TransformationContext context) {
		if (findDeclaredMethod(methodName) == null) {
			return addMethod(methodName) [
				returnType = String.newTypeReference
				addAnnotation(ClassName.newTypeReference.type) => [
					setStringValue('value', className)
				]
			]
		}
		addMethod('''«methodName»Class''', className, context)
	}

	def getMethodName(String className) {
		val sb = new StringBuilder()
		var c = className.charAt(0)
		if (Character.isJavaIdentifierStart(c)) {
			sb.append(Character.toLowerCase(c))
		}

		var i = 0
		val j = className.length
		var nextUpCase = false
		while (i + 1 < j) {
			i = i + 1
			c = className.charAt(i)
			if (!Character.isJavaIdentifierPart(c)) {
				nextUpCase = true
			} else {
				if (nextUpCase) {
					nextUpCase = false
					c = Character.toUpperCase(c)
				}
				sb.append(c)
			}
		}
		return sb.toString();
	}

	def List<String> getCsses(AnnotationReference it) {
		switch value : getValue('csses') {
			String: #[value]
			String[]: value
		}
	}

	def getValue(AnnotationReference it) {
		getStringValue('value')
	}

	def getCssResources(InterfaceDeclaration it) {
		annotations.filter[annotationTypeDeclaration.qualifiedName == CssResource.name]
	}

	def getCssResources(MutableInterfaceDeclaration it) {
		annotations.filter[annotationTypeDeclaration.qualifiedName == CssResource.name]
	}

}
