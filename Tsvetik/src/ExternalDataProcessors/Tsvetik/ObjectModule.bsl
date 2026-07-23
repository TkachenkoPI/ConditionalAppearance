#Region Variables

Var ConditionalAppearance;
Var AppearanceItem;
Var CurrentItem;
Var WebColorsCache;

#EndRegion

#Region Public

// Sets the conditional appearance the object works with. Must be called first.
// Ru: Устанавливает условное оформление, с которым работает объект. Вызывается первым.
//
// Parameters:
//  NewConditionalAppearance - DataCompositionConditionalAppearance - form conditional appearance.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Set
Function Set(NewConditionalAppearance) Export

	ConditionalAppearance = NewConditionalAppearance;
	AppearanceItem = Undefined;
	CurrentItem = Undefined;

	Return ThisObject;

EndFunction

// Form item or items the conditional appearance is applied to.
// Ru: Элемент или элементы формы, к которым применяется условное оформление.
//
// Parameters:
//  Names - String - form item name. Several names can be passed separated by ",".
//        - FormTable, FormField, FormGroup - object must have the "Name" property.
//        - Array Of String -
//        - Array Of FormTable, FormField, FormGroup -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Item
Function Item(Names) Export

	CheckConditionalAppearance();

	AppearanceItem = ConditionalAppearance.Items.Add();
	CurrentItem = AppearanceItem;

	If TypeOf(Names) = Type("Array") Then

		For Each Name In Names Do
			AddAppearanceField(Name);
		EndDo;

	Else
		AddAppearanceField(Names);
	EndIf;

	Return ThisObject;

EndFunction

// Clears the conditional appearance.
// Ru: Очищает условное оформление.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Clear
Function Clear() Export

	CheckConditionalAppearance();

	ConditionalAppearance.Items.Clear();

	AppearanceItem = Undefined;
	CurrentItem = Undefined;

	Return ThisObject;

EndFunction

// Sets an appearance parameter by name. Base method for all appearance wrappers.
// Ru: Задает параметр оформления по имени. Базовый метод для всех оберток оформления.
//
// Parameters:
//  Property - String - for example "MarkIncomplete".
//  Value - Arbitrary -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Appearance
Function Appearance(Property, Value) Export

	CheckItem();

	AppearanceItem.Appearance.SetParameterValue(Property, Value);

	Return ThisObject;

EndFunction

// Generates source code for the current conditional appearance so it can be copied into a module.
// Ru: Генерирует исходный код по текущему условному оформлению, чтобы его можно было скопировать в модуль.
//
// The generated code is always English and does not depend on the interface language.
// Ru: Сгенерированный код всегда английский и не зависит от языка интерфейса.
//
// Returns:
//  String - ready to use code
Function GenerateCode() Export

	CheckConditionalAppearance();

	BaseIndent = 1;

	Result = "Tsvetik.Set(ConditionalAppearance)";
	Result = Result + Chars.LF + Indent(BaseIndent) + ".Clear()";

	ItemTemplate = Chars.LF + Indent(BaseIndent) + ".Item(""%1"")";
	AppearanceTemplate = Chars.LF + Indent(BaseIndent + 1) + ".Appearance(""%1"", %2)";

	For Each AppearanceElement In ConditionalAppearance.Items Do

		If Not AppearanceElement.Use Then
			Continue;
		EndIf;

		Result = Result + StrTemplate(ItemTemplate, FieldsPresentation(AppearanceElement.Fields));

		ParseFilter(Result, AppearanceElement.Filter, BaseIndent + 1);

		For Each AppearanceValue In AppearanceElement.Appearance.Items Do

			If Not AppearanceValue.Use Then
				Continue;
			EndIf;

			Result = Result + StrTemplate(AppearanceTemplate,
				AppearanceParameterName(AppearanceValue.Parameter),
				ValueToCode(AppearanceValue.Value));
		EndDo;

	EndDo;

	Return Result + ";";

EndFunction

#Region Groups

// Opens an AND group that filters can be placed into.
// Ru: Открывает группу И, в которую можно поместить отборы.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - AndGroup
Function AndGroup() Export

	AddGroup(DataCompositionFilterItemsGroupType.AndGroup);

	Return ThisObject;

EndFunction

// Opens an OR group that filters can be placed into.
// Ru: Открывает группу ИЛИ, в которую можно поместить отборы.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - OrGroup
Function OrGroup() Export

	AddGroup(DataCompositionFilterItemsGroupType.OrGroup);

	Return ThisObject;

EndFunction

// Opens a NOT group that filters can be placed into.
// Ru: Открывает группу НЕ, в которую можно поместить отборы.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotGroup
Function NotGroup() Export

	AddGroup(DataCompositionFilterItemsGroupType.NotGroup);

	Return ThisObject;

EndFunction

// Closes the current group and returns one level up. Needed for nested conditions.
// Ru: Закрывает текущую группу и возвращает на уровень выше. Нужно для вложенных условий.
//
//    Tsvetik.Set(ConditionalAppearance)
//		.Clear()
//		.Item("Attribute2")
//			.AndGroup()
//				.OrGroup()
//					.Equal("Attribute3", True)
//					.BeginsWith("Attribute4", "a")
//				.EndGroup()
//				.AndGroup()
//					.Equal("Attribute1", True)
//				.EndGroup()
//			.EndGroup()
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - EndGroup
Function EndGroup() Export

	CheckItem();

	If TypeOf(CurrentItem) <> Type("DataCompositionFilterItemGroup") Then
		Raise NStr("en = 'EndGroup is called without an open filter group'", "en");
	EndIf;

	Parent = CurrentItem.Parent;

	If TypeOf(Parent) = Type("DataCompositionFilterItemGroup") Then
		CurrentItem = Parent;
	Else
		CurrentItem = AppearanceItem;
	EndIf;

	Return ThisObject;

EndFunction

#EndRegion

#Region Filters

// Equal.
// Ru: Равно.
//
// Parameters:
//  Field - FormTable, FormField - object must have the "DataPath" property.
//        - String - for example "Object.Goods.ProductType", "Object.Status".
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Equal
Function Equal(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.Equal, Value);

EndFunction

// Not equal.
// Ru: Не равно.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotEqual
Function NotEqual(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotEqual, Value);

EndFunction

// Greater.
// Ru: Больше.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Greater
Function Greater(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.Greater, Value);

EndFunction

// Greater or equal.
// Ru: Больше или равно.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - GreaterOrEqual
Function GreaterOrEqual(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.GreaterOrEqual, Value);

EndFunction

// Less.
// Ru: Меньше.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Less
Function Less(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.Less, Value);

EndFunction

// Less or equal.
// Ru: Меньше или равно.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - LessOrEqual
Function LessOrEqual(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.LessOrEqual, Value);

EndFunction

// In list.
// Ru: В списке.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Array, ValueList - list of values.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - InList
Function InList(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.InList, Value);

EndFunction

// Not in list.
// Ru: Не в списке.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Array, ValueList - list of values.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotInList
Function NotInList(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotInList, Value);

EndFunction

// In hierarchy. Only makes sense for reference fields with hierarchy.
// Ru: В иерархии. Имеет смысл только для ссылочных полей с иерархией.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - InHierarchy
Function InHierarchy(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.InHierarchy, Value);

EndFunction

// Not in hierarchy. Only makes sense for reference fields with hierarchy.
// Ru: Не в иерархии. Имеет смысл только для ссылочных полей с иерархией.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotInHierarchy
Function NotInHierarchy(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotInHierarchy, Value);

EndFunction

// In list by hierarchy. Only makes sense for reference fields with hierarchy.
// Ru: В списке по иерархии. Имеет смысл только для ссылочных полей с иерархией.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Array, ValueList - list of values.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - InListByHierarchy
Function InListByHierarchy(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.InListByHierarchy, Value);

EndFunction

// Not in list by hierarchy. Only makes sense for reference fields with hierarchy.
// Ru: Не в списке по иерархии. Имеет смысл только для ссылочных полей с иерархией.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Array, ValueList - list of values.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotInListByHierarchy
Function NotInListByHierarchy(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotInListByHierarchy, Value);

EndFunction

// Contains.
// Ru: Содержит.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - String - substring.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Contains
Function Contains(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.Contains, Value);

EndFunction

// Not contains.
// Ru: Не содержит.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - String - substring.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotContains
Function NotContains(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotContains, Value);

EndFunction

// Like. Supports the "%" and "_" patterns.
// Ru: Подобно. Поддерживает шаблоны "%" и "_".
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - String - pattern.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Like
Function Like(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.Like, Value);

EndFunction

// Not like. Supports the "%" and "_" patterns.
// Ru: Не подобно. Поддерживает шаблоны "%" и "_".
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - String - pattern.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotLike
Function NotLike(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotLike, Value);

EndFunction

// Begins with.
// Ru: Начинается с.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - String - prefix.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - BeginsWith
Function BeginsWith(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.BeginsWith, Value);

EndFunction

// Not begins with.
// Ru: Не начинается с.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - String - prefix.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotBeginsWith
Function NotBeginsWith(Field, Value) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotBeginsWith, Value);

EndFunction

// Filled.
// Ru: Заполнено.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - not used, this comparison type needs no right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Filled
Function Filled(Field, Value = Undefined) Export

	Return AddFilter(Field, DataCompositionComparisonType.Filled, Value);

EndFunction

// Not filled.
// Ru: Не заполнено.
//
// Parameters:
//  Field - FormTable, FormField, String - filtered field.
//  Value - Arbitrary - not used, this comparison type needs no right value.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - NotFilled
Function NotFilled(Field, Value = Undefined) Export

	Return AddFilter(Field, DataCompositionComparisonType.NotFilled, Value);

EndFunction

#EndRegion

#Region Appearance

// Sets the "BackColor" appearance parameter.
// Ru: Задает параметр оформления "Цвет фона".
//
// Parameters:
//  Color - Color -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - BackColor
Function BackColor(Color) Export

	Return Appearance("BackColor", Color);

EndFunction

// Sets the "TextColor" appearance parameter.
// Ru: Задает параметр оформления "Цвет текста".
//
// Parameters:
//  Color - Color -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - TextColor
Function TextColor(Color) Export

	Return Appearance("TextColor", Color);

EndFunction

// Sets the "Font" appearance parameter.
// Ru: Задает параметр оформления "Шрифт".
//
// Parameters:
//  Value - Font -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Font
Function Font(Value) Export

	Return Appearance("Font", Value);

EndFunction

// Sets the "HorizontalAlign" appearance parameter.
// Ru: Задает параметр оформления "Горизонтальное положение".
//
// Parameters:
//  Value - HorizontalAlign - for example HorizontalAlign.Left, HorizontalAlign.Right.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - HorizontalAlign
Function HorizontalAlign(Value) Export

	Return Appearance("HorizontalAlign", Value);

EndFunction

// Sets the "MarkNegatives" appearance parameter.
// Ru: Задает параметр оформления "Выделять отрицательные".
//
// Parameters:
//  Value - Boolean -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - MarkNegatives
Function MarkNegatives(Value) Export

	Return Appearance("MarkNegatives", Value);

EndFunction

// Sets the "MarkIncomplete" appearance parameter.
// Ru: Задает параметр оформления "Отметка незаполненного".
//
// Parameters:
//  Value - Boolean -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - MarkIncomplete
Function MarkIncomplete(Value) Export

	Return Appearance("MarkIncomplete", Value);

EndFunction

// Sets the "Visible" appearance parameter. Controls the item itself.
// Ru: Задает параметр оформления "Видимость". Управляет самим элементом.
//
// WARNING: works only for form table items - a column or the table itself.
// On a plain form field outside a table it silently does nothing: no exception,
// the field stays visible. Such a field can only be hidden by code:
//    Items.Attribute1.Visible = False;
// Ru: Работает только для элементов таблицы формы. На обычном поле формы молча не срабатывает.
//
// Parameters:
//  Value - Boolean -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Visible
Function Visible(Value) Export

	Return Appearance("Visible", Value);

EndFunction

// Sets the "Show" appearance parameter. Controls value output, not the item itself.
// Ru: Задает параметр оформления "Отображать". Управляет выводом значения, а не самим элементом.
//
// WARNING: like "Visible", works only for form table items.
// Ru: Как и "Видимость", работает только для элементов таблицы формы.
//
// Parameters:
//  Value - Boolean -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Show
Function Show(Value) Export

	Return Appearance("Show", Value);

EndFunction

// Sets the "Enabled" appearance parameter.
// Ru: Задает параметр оформления "Доступность".
//
// Parameters:
//  Value - Boolean -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Enabled
Function Enabled(Value) Export

	Return Appearance("Enabled", Value);

EndFunction

// Sets the "ReadOnly" appearance parameter.
// Ru: Задает параметр оформления "Только просмотр".
//
// Parameters:
//  Value - Boolean -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - ReadOnly
Function ReadOnly(Value) Export

	Return Appearance("ReadOnly", Value);

EndFunction

// Sets the "Text" appearance parameter - replaces the displayed value.
// Ru: Задает параметр оформления "Текст" - подменяет отображаемое значение.
//
// Parameters:
//  Value - String, FormattedString, DataCompositionField -
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - Text
Function Text(Value) Export

	Return Appearance("Text", Value);

EndFunction

// The "Format" parameter is set through Appearance("Format", "ND=10; NFD=2"):
// the name "Format" belongs to a global platform function, so a wrapper cannot be named that way.
// Ru: Параметр "Формат" задается через Appearance("Format", ...): имя занято глобальной функцией платформы.

#EndRegion

#EndRegion

#Region Private

#Region Building

Function AddFilter(Field, ComparisonType, Value)

	FilterItem = FilterContainer().Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField(FieldAdapter(Field));
	FilterItem.ComparisonType = ComparisonType;
	FilterItem.RightValue = Value;

	Return ThisObject;

EndFunction

Procedure AddGroup(GroupType)

	FilterGroup = FilterContainer().Items.Add(Type("DataCompositionFilterItemGroup"));
	FilterGroup.GroupType = GroupType;

	CurrentItem = FilterGroup;

EndProcedure

// Collection that filters and filter groups are added to.
// If no group is open this is the filter of the appearance item itself.
// Ru: Коллекция, в которую добавляются отборы. Без открытой группы - отбор самого элемента.
//
// Returns:
//  DataCompositionFilter, DataCompositionFilterItemGroup - filter container
Function FilterContainer()

	CheckItem();

	If TypeOf(CurrentItem) = Type("DataCompositionConditionalAppearanceItem") Then
		Return CurrentItem.Filter;
	EndIf;

	Return CurrentItem;

EndFunction

Procedure AddAppearanceField(Source)

	If TypeOf(Source) = Type("String") Then

		For Each NamePart In StrSplit(Source, ",", False) Do

			Name = TrimAll(NamePart);

			If ValueIsFilled(Name) Then
				AddDataCompositionField(Name);
			EndIf;

		EndDo;

		Return;
	EndIf;

	AddDataCompositionField(FormItemName(Source));

EndProcedure

Procedure AddDataCompositionField(Name)

	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField(Name);

EndProcedure

Function FormItemName(Source)

	CheckStructure = New Structure("Name", "");
	FillPropertyValues(CheckStructure, Source);

	If Not ValueIsFilled(CheckStructure.Name) Then
		Raise StrTemplate(NStr(
			"en = 'Cannot determine the appearance item. A string or a form item with the ""Name"" property was expected, got: %1'",
			"en"), String(TypeOf(Source)));
	EndIf;

	Return CheckStructure.Name;

EndFunction

Function FieldAdapter(Field)

	If TypeOf(Field) = Type("String") Then
		Return TrimAll(Field);
	EndIf;

	CheckStructure = New Structure("DataPath", "");
	FillPropertyValues(CheckStructure, Field);

	If Not ValueIsFilled(CheckStructure.DataPath) Then
		Raise StrTemplate(NStr(
			"en = 'Cannot determine the filter field. A string or a form item with the ""DataPath"" property was expected, got: %1'",
			"en"), String(TypeOf(Field)));
	EndIf;

	Return CheckStructure.DataPath;

EndFunction

Procedure CheckConditionalAppearance()

	If ConditionalAppearance = Undefined Then
		Raise NStr("en = 'Call the ""Set"" method first and pass the form conditional appearance'", "en");
	EndIf;

EndProcedure

Procedure CheckItem()

	CheckConditionalAppearance();

	If AppearanceItem = Undefined Then
		Raise NStr("en = 'Call the ""Item"" method first'", "en");
	EndIf;

EndProcedure

#EndRegion

#Region CodeGeneration

Procedure ParseFilter(Result, Filter, IndentLevel)

	For Each FilterElement In Filter.Items Do

		If Not FilterElement.Use Then
			Continue;
		EndIf;

		If TypeOf(FilterElement) = Type("DataCompositionFilterItemGroup") Then

			If FilterElement.GroupType = DataCompositionFilterItemsGroupType.AndGroup Then
				GroupPresentation = "AndGroup";
			ElsIf FilterElement.GroupType = DataCompositionFilterItemsGroupType.OrGroup Then
				GroupPresentation = "OrGroup";
			Else // NotGroup
				GroupPresentation = "NotGroup";
			EndIf;

			Result = Result + StrTemplate(GroupTemplate(IndentLevel), GroupPresentation);

			ParseFilter(Result, FilterElement, IndentLevel + 1);

			Result = Result + EndGroupTemplate(IndentLevel);

		ElsIf TypeOf(FilterElement) = Type("DataCompositionFilterItem") Then

			Result = Result + StrTemplate(FilterItemTemplate(IndentLevel),
				ComparisonTypePresentation(FilterElement.ComparisonType),
				String(FilterElement.LeftValue),
				ValueToCode(FilterElement.RightValue));

		EndIf;

	EndDo;

EndProcedure

Function FieldsPresentation(Fields)

	Names = New Array;

	For Each AppearanceField In Fields.Items Do
		Names.Add(String(AppearanceField.Field));
	EndDo;

	Return StrConcat(Names, ", ");

EndFunction

// English method name for a comparison type.
// Built from the enum values, not from String(), so the result does not depend
// on the interface language and stays English in a Russian session.
// Ru: Английское имя вида сравнения. Строится по значениям перечисления, а не через Строка(),
// Ru: поэтому результат не зависит от языка интерфейса и остается английским в русском сеансе.
//
// Returns:
//  String - for example "GreaterOrEqual"
Function ComparisonTypePresentation(ComparisonType)

	Names = New Map;

	Names.Insert(DataCompositionComparisonType.Equal, "Equal");
	Names.Insert(DataCompositionComparisonType.NotEqual, "NotEqual");
	Names.Insert(DataCompositionComparisonType.Greater, "Greater");
	Names.Insert(DataCompositionComparisonType.GreaterOrEqual, "GreaterOrEqual");
	Names.Insert(DataCompositionComparisonType.Less, "Less");
	Names.Insert(DataCompositionComparisonType.LessOrEqual, "LessOrEqual");
	Names.Insert(DataCompositionComparisonType.InList, "InList");
	Names.Insert(DataCompositionComparisonType.NotInList, "NotInList");
	Names.Insert(DataCompositionComparisonType.InHierarchy, "InHierarchy");
	Names.Insert(DataCompositionComparisonType.NotInHierarchy, "NotInHierarchy");
	Names.Insert(DataCompositionComparisonType.InListByHierarchy, "InListByHierarchy");
	Names.Insert(DataCompositionComparisonType.NotInListByHierarchy, "NotInListByHierarchy");
	Names.Insert(DataCompositionComparisonType.Contains, "Contains");
	Names.Insert(DataCompositionComparisonType.NotContains, "NotContains");
	Names.Insert(DataCompositionComparisonType.Like, "Like");
	Names.Insert(DataCompositionComparisonType.NotLike, "NotLike");
	Names.Insert(DataCompositionComparisonType.BeginsWith, "BeginsWith");
	Names.Insert(DataCompositionComparisonType.NotBeginsWith, "NotBeginsWith");
	Names.Insert(DataCompositionComparisonType.Filled, "Filled");
	Names.Insert(DataCompositionComparisonType.NotFilled, "NotFilled");

	Presentation = Names.Get(ComparisonType);

	Return ?(Presentation = Undefined, String(ComparisonType), Presentation);

EndFunction

// English name of an appearance parameter.
// String(Parameter) returns the name in the interface language, so in a Russian session
// it gives "ЦветФона". The table maps both spellings back to the English name.
// Ru: Английское имя параметра оформления. Строка(Параметр) возвращает имя на языке интерфейса,
// Ru: поэтому таблица приводит оба написания к английскому.
//
// Returns:
//  String - for example "BackColor"
Function AppearanceParameterName(Parameter)

	Presentation = String(Parameter);

	Names = New Map;

	Names.Insert(NameKey("BackColor"), "BackColor");
	Names.Insert(NameKey("ЦветФона"), "BackColor");
	Names.Insert(NameKey("TextColor"), "TextColor");
	Names.Insert(NameKey("ЦветТекста"), "TextColor");
	Names.Insert(NameKey("Font"), "Font");
	Names.Insert(NameKey("Шрифт"), "Font");
	Names.Insert(NameKey("HorizontalAlign"), "HorizontalAlign");
	Names.Insert(NameKey("ГоризонтальноеПоложение"), "HorizontalAlign");
	Names.Insert(NameKey("MarkNegatives"), "MarkNegatives");
	Names.Insert(NameKey("ВыделятьОтрицательные"), "MarkNegatives");
	Names.Insert(NameKey("MarkIncomplete"), "MarkIncomplete");
	Names.Insert(NameKey("ОтметкаНезаполненного"), "MarkIncomplete");
	Names.Insert(NameKey("Visible"), "Visible");
	Names.Insert(NameKey("Видимость"), "Visible");
	Names.Insert(NameKey("Show"), "Show");
	Names.Insert(NameKey("Отображать"), "Show");
	Names.Insert(NameKey("Enabled"), "Enabled");
	Names.Insert(NameKey("Доступность"), "Enabled");
	Names.Insert(NameKey("ReadOnly"), "ReadOnly");
	Names.Insert(NameKey("ТолькоПросмотр"), "ReadOnly");
	Names.Insert(NameKey("Text"), "Text");
	Names.Insert(NameKey("Текст"), "Text");
	Names.Insert(NameKey("Format"), "Format");
	Names.Insert(NameKey("Формат"), "Format");

	EnglishName = Names.Get(NameKey(Presentation));

	// An unknown parameter is printed as the platform returned it.
	// Ru: Неизвестный параметр печатается так, как его вернула платформа.
	Return ?(EnglishName = Undefined, Presentation, EnglishName);

EndFunction

// Value as a built-in language literal.
// Types that cannot be expressed as a literal produce a visible placeholder.
// Ru: Значение в виде литерала встроенного языка. Невыразимые типы дают заметный плейсхолдер.
//
// Returns:
//  String - code fragment
Function ValueToCode(Value)

	ValueType = TypeOf(Value);

	If ValueType = Type("String") Then
		Return """" + StrReplace(Value, """", """""") + """";

	ElsIf ValueType = Type("Boolean") Then
		Return ?(Value, "True", "False");

	ElsIf ValueType = Type("Number") Then
		Return Format(Value, "NG=0; NDS=.; NZ=0");

	ElsIf ValueType = Type("Date") Then
		Return "'" + Format(Value, "DF=yyyyMMddHHmmss") + "'";

	ElsIf ValueType = Type("Color") Then
		Return ColorValue(Value);

	ElsIf ValueType = Type("HorizontalAlign") Then
		Return HorizontalAlignValue(Value);

	EndIf;

	Return ValuePlaceholder();

EndFunction

Function ColorValue(Color)

	Return StrTemplate("WebColors.%1", WebColorIdentifier(Color));

EndFunction

// English identifier of a web color.
// The name is recognized both in Russian and in English, because the platform returns
// the presentation in the interface language. An unknown color falls back to the default one.
// Ru: Английский идентификатор web-цвета. Имя распознается и на русском, и на английском,
// Ru: так как платформа возвращает представление на языке интерфейса.
// Ru: Нераспознанный цвет заменяется цветом по умолчанию.
//
// Returns:
//  String - for example "LightSalmon"
Function WebColorIdentifier(Color)

	If Color.Type <> ColorType.WebColor Then
		Return DefaultColor();
	EndIf;

	Presentation = String(Color);

	// The platform may return "Лосось светлый (LightSalmon)" or just one of the names.
	// Ru: Платформа может вернуть "Лосось светлый (LightSalmon)" или одно из имен.
	RussianName = Presentation;
	EnglishName = "";

	OpeningBracket = StrFind(Presentation, "(");

	If OpeningBracket <> 0 Then

		RussianName = Mid(Presentation, 1, OpeningBracket - 1);

		ClosingBracket = StrFind(Presentation, ")");

		If ClosingBracket > OpeningBracket Then
			EnglishName = Mid(Presentation, OpeningBracket + 1, ClosingBracket - OpeningBracket - 1);
		EndIf;

	EndIf;

	Colors = WebColorsByName();

	Identifier = Colors.Get(NameKey(RussianName));

	If Identifier = Undefined Then
		Identifier = Colors.Get(NameKey(EnglishName));
	EndIf;

	Return ?(Identifier = Undefined, DefaultColor(), Identifier);

EndFunction

Function DefaultColor()

	Return "LightSalmon";

EndFunction

// Lookup key: no spaces, no hyphens, no case.
// Ru: Ключ поиска: без пробелов, дефисов и регистра.
Function NameKey(Name)

	Return Upper(StrReplace(StrReplace(TrimAll(Name), " ", ""), "-", ""));

EndFunction

Procedure AddWebColor(RussianName, EnglishName)

	WebColorsCache.Insert(NameKey(RussianName), EnglishName);
	WebColorsCache.Insert(NameKey(EnglishName), EnglishName);

EndProcedure

// Platform web colors: both spellings map to the English identifier.
// Ru: Web-цвета платформы: оба написания приводятся к английскому идентификатору.
//
// Returns:
//  Map Of KeyAndValue:
//   * Key - String - color name without spaces, hyphens and case
//   * Value - String - identifier for code, for example "LightSalmon"
Function WebColorsByName()

	If WebColorsCache <> Undefined Then
		Return WebColorsCache;
	EndIf;

	WebColorsCache = New Map;

	// Whites and grays
	AddWebColor("Белый", "White");
	AddWebColor("Белоснежный", "Snow");
	AddWebColor("Роса", "HoneyDew");
	AddWebColor("Мятный крем", "MintCream");
	AddWebColor("Лазурный", "Azure");
	AddWebColor("Акварельно-синий", "AliceBlue");
	AddWebColor("Призрачно-белый", "GhostWhite");
	AddWebColor("Дымчато-белый", "WhiteSmoke");
	AddWebColor("Перламутровый", "SeaShell");
	AddWebColor("Бежевый", "Beige");
	AddWebColor("Старое кружево", "OldLace");
	AddWebColor("Кремовый", "Cream");
	AddWebColor("Цветок Белый", "FloralWhite");
	AddWebColor("Слоновая Кость", "Ivory");
	AddWebColor("АнтикБелый", "AntiqueWhite");
	AddWebColor("Льняной", "Linen");
	AddWebColor("Голубой с красным оттенком", "LavenderBlush");
	AddWebColor("Тускло-розовый", "MistyRose");
	AddWebColor("Серебристо-серый", "Gainsboro");
	AddWebColor("Светло-серый", "LightGray");
	AddWebColor("Серебряный", "Silver");
	AddWebColor("Темно-серый", "DarkGray");
	AddWebColor("Нейтрально-серый", "MediumGray");
	AddWebColor("Серый", "Gray");
	AddWebColor("Тускло-серый", "DimGray");
	AddWebColor("Светло-грифельно-серый", "LightSlateGray");
	AddWebColor("Грифельно-серый", "SlateGray");
	AddWebColor("Темно-грифельно-серый", "DarkSlateGray");
	AddWebColor("Черный", "Black");

	// Reds and pinks
	AddWebColor("Киноварь", "IndianRed");
	AddWebColor("Светло-коралловый", "LightCoral");
	AddWebColor("Лосось", "Salmon");
	AddWebColor("Лосось Темный", "DarkSalmon");
	AddWebColor("Лосось светлый", "LightSalmon");
	AddWebColor("Малиновый", "Crimson");
	AddWebColor("Красный", "Red");
	AddWebColor("Кирпичный", "FireBrick");
	AddWebColor("Темно-красный", "DarkRed");
	AddWebColor("Розовый", "Pink");
	AddWebColor("Светло-розовый", "LightPink");
	AddWebColor("Тепло-розовый", "HotPink");
	AddWebColor("Насыщенно-розовый", "DeepPink");
	AddWebColor("Нейтрально-фиолетово-красный", "MediumVioletRed");
	AddWebColor("Красно-фиолетовый", "VioletRed");
	AddWebColor("Бледно-красно-фиолетовый", "PaleVioletRed");

	// Oranges and yellows
	AddWebColor("Коралловый", "Coral");
	AddWebColor("Томатный", "Tomato");
	AddWebColor("Оранжево-красный", "OrangeRed");
	AddWebColor("Темно-оранжевый", "DarkOrange");
	AddWebColor("Оранжевый", "Orange");
	AddWebColor("Золотой", "Gold");
	AddWebColor("Желтый", "Yellow");
	AddWebColor("Светло-желтый", "LightYellow");
	AddWebColor("Лимонный", "LemonChiffon");
	AddWebColor("Светло-желтый золотистый", "LightGoldenrodYellow");
	AddWebColor("Топленое молоко", "PapayaWhip");
	AddWebColor("Замша Светлый", "Moccasin");
	AddWebColor("Персиковый", "PeachPuff");
	AddWebColor("Бледно-золотистый", "PaleGoldenrod");
	AddWebColor("Хаки", "Khaki");
	AddWebColor("Хаки Темный", "DarkKhaki");

	// Browns
	AddWebColor("Шелковый оттенок", "CornSilk");
	AddWebColor("Бледно-Миндальный", "BlanchedAlmond");
	AddWebColor("Светло-коричневый", "Bisque");
	AddWebColor("Навахо Белый", "NavajoWhite");
	AddWebColor("Пшеничный", "Wheat");
	AddWebColor("Древесный", "BurlyWood");
	AddWebColor("Рыжевато-коричневый", "Tan");
	AddWebColor("Розово-коричневый", "RosyBrown");
	AddWebColor("Песочно-коричневый", "SandyBrown");
	AddWebColor("Светло-золотистый", "LightGoldenrod");
	AddWebColor("Золотистый", "Goldenrod");
	AddWebColor("Темно-золотистый", "DarkGoldenRod");
	AddWebColor("Нейтрально-коричневый", "Peru");
	AddWebColor("Шоколадный", "Chocolate");
	AddWebColor("Кожано-коричневый", "SaddleBrown");
	AddWebColor("Охра", "Sienna");
	AddWebColor("Коричневый", "Brown");
	AddWebColor("Темно-бордовый", "Maroon");

	// Purples
	AddWebColor("Бледно-лиловый", "Lavender");
	AddWebColor("Бледно-сиреневый", "Thistle");
	AddWebColor("Сливовый", "Plum");
	AddWebColor("Фиолетовый", "Violet");
	AddWebColor("Орхидея", "Orchid");
	AddWebColor("Фуксия", "Fuchsia");
	AddWebColor("Фуксин", "Magenta");
	AddWebColor("Орхидея Нейтральный", "MediumOrchid");
	AddWebColor("Нейтрально-пурпурный", "MediumPurple");
	AddWebColor("Сине-фиолетовый", "BlueViolet");
	AddWebColor("Темно-фиолетовый", "DarkViolet");
	AddWebColor("Орхидея Темный", "DarkOrchid");
	AddWebColor("Фуксин Темный", "DarkMagenta");
	AddWebColor("Пурпурный", "Purple");
	AddWebColor("Индиго", "Indigo");
	AddWebColor("Светло-грифельно-синий", "LightSlateBlue");
	AddWebColor("Грифельно-синий", "SlateBlue");
	AddWebColor("Темно-грифельно-синий", "DarkSlateBlue");
	AddWebColor("Нейтрально-грифельно-синий", "MediumSlateBlue");

	// Greens
	AddWebColor("Зелено-желтый", "GreenYellow");
	AddWebColor("Зеленовато-желтый", "Chartreuse");
	AddWebColor("Зеленая лужайка", "LawnGreen");
	AddWebColor("Зеленовато-лимонный", "Lime");
	AddWebColor("Лимонно-зеленый", "LimeGreen");
	AddWebColor("Бледно-зеленый", "PaleGreen");
	AddWebColor("Светло-зеленый", "LightGreen");
	AddWebColor("Нейтрально-весенне-зеленый", "MediumSpringGreen");
	AddWebColor("Весенне-зеленый", "SpringGreen");
	AddWebColor("Цвет морской волны Нейтральный", "MediumSeaGreen");
	AddWebColor("Цвет морской волны", "Seagreen");
	AddWebColor("Зеленый лес", "ForestGreen");
	AddWebColor("Зеленый", "Green");
	AddWebColor("Нейтрально-зеленый", "MediumGreen");
	AddWebColor("Темно-зеленый", "DarkGreen");
	AddWebColor("Желто-зеленый", "YellowGreen");
	AddWebColor("Тускло-оливковый", "OliveRab");
	AddWebColor("Оливковый", "Olive");
	AddWebColor("Темно-оливково-зеленый", "DarkOliveGreen");

	// Turquoises
	AddWebColor("Нейтрально-аквамариновый", "MediumAquaMarine");
	AddWebColor("Цвет морской волны Темный", "DarkSeaGreen");
	AddWebColor("Цвет морской волны Светлый", "LightSeaGreen");
	AddWebColor("Циан Темный", "DarkCyan");
	AddWebColor("Циан Нейтральный", "Teal");
	AddWebColor("Циан акварельный", "Aqua");
	AddWebColor("Циан", "Cyan");
	AddWebColor("Циан светлый", "LightCyan");
	AddWebColor("Бледно-бирюзовый", "PaleTurquoise");
	AddWebColor("Аквамарин", "Aquamarine");
	AddWebColor("Бирюзовый", "Turquoise");
	AddWebColor("Нейтрально-бирюзовый", "MediumTurquoise");
	AddWebColor("Темно-бирюзовый", "DarkTurquoise");

	// Blues
	AddWebColor("Серо-синий", "CadetBlue");
	AddWebColor("Синий со стальным оттенком", "SteelBlue");
	AddWebColor("Голубой со стальным оттенком", "LightSteelBlue");
	AddWebColor("Синий с пороховым оттенком", "PowderBlue");
	AddWebColor("Голубой", "LightBlue");
	AddWebColor("Небесно-голубой", "SkyBlue");
	AddWebColor("Светло-небесно-голубой", "LightSkyBlue");
	AddWebColor("Насыщенно-небесно-голубой", "DeepSkyBlue");
	AddWebColor("Сине-серый", "DodgerBlue");
	AddWebColor("Васильковый", "CornFlowerBlue");
	AddWebColor("Королевский Голубой", "RoyalBlue");
	AddWebColor("Синий", "Blue");
	AddWebColor("Нейтрально-синий", "MediumBlue");
	AddWebColor("Темно-синий", "DarkBlue");
	AddWebColor("Ультрамарин", "Navy");
	AddWebColor("Полночно-синий", "MidnightBlue");

	Return WebColorsCache;

EndFunction

Function HorizontalAlignValue(Value)

	Names = New Map;

	Names.Insert(HorizontalAlign.Auto, "HorizontalAlign.Auto");
	Names.Insert(HorizontalAlign.Left, "HorizontalAlign.Left");
	Names.Insert(HorizontalAlign.Center, "HorizontalAlign.Center");
	Names.Insert(HorizontalAlign.Right, "HorizontalAlign.Right");
	Names.Insert(HorizontalAlign.Justify, "HorizontalAlign.Justify");

	Presentation = Names.Get(Value);

	Return ?(Presentation = Undefined, ValuePlaceholder(), Presentation);

EndFunction

Function ValuePlaceholder()

	Return "_PutValueHere_";

EndFunction

Function Indent(Times)

	Result = "";

	For Counter = 1 To Times Do
		Result = Result + Chars.Tab;
	EndDo;

	Return Result;

EndFunction

Function GroupTemplate(IndentLevel)

	Return Chars.LF + Indent(IndentLevel) + ".%1()";

EndFunction

Function FilterItemTemplate(IndentLevel)

	Return Chars.LF + Indent(IndentLevel) + ".%1(""%2"", %3)";

EndFunction

Function EndGroupTemplate(IndentLevel)

	Return Chars.LF + Indent(IndentLevel) + ".EndGroup()";

EndFunction

#EndRegion

#EndRegion
