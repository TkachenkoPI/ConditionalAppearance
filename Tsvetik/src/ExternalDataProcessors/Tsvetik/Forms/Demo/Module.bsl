#Region FormCommandsEventHandlers

&AtClient
Procedure GenerateCodeForCurrentAppearance(Command)

	GenerateCodeForCurrentAppearanceAtServer();

EndProcedure

&AtClient
Procedure ClearConditionalAppearance(Command)
	ClearConditionalAppearanceAtServer();
EndProcedure

&AtClient
Procedure ApplyConditionalAppearance(Command)
	ApplyConditionalAppearanceAtServer();
EndProcedure

&AtClient
Procedure Test1(Command)

	Attribute2 = 5;

	Test1AtServer();

EndProcedure

&AtClient
Procedure Test2(Command)

	Attribute2 = 0;
	Attribute3 = False;
	Attribute4 = True;

	Test2AtServer();

EndProcedure

&AtClient
Procedure Test3(Command)

	Attribute3 = True;

	Test3AtServer();

EndProcedure

&AtClient
Procedure Test4(Command)

	Attribute2 = 0;

	Test4AtServer();

EndProcedure

&AtClient
Procedure Test5(Command)

	Attribute2 = 0;

	Composition.Clear();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	Test5AtServer();

EndProcedure

&AtClient
Procedure Test6(Command)

	Attribute2 = 0;

	Composition.Clear();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	Test6AtServer();

EndProcedure

&AtClient
Procedure Test7(Command)

	Attribute3 = True;

	Composition.Clear();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	Test7AtServer();

EndProcedure

&AtClient
Procedure Test8(Command)

	Composition.Clear();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	NewRow = Composition.Add();
	NewRow.Attribute3 = True;
	NewRow = Composition.Add();

	Test8AtServer();

EndProcedure

&AtClient
Procedure MegaTest(Command)

	MegaTestAtServer();

EndProcedure

&AtClient
Procedure VisibilityTest(Command)
	VisibilityTestAtServer();
EndProcedure

#EndRegion

#Region Private

// External data processor object prepared to work with the conditional appearance of this form.
// Ru: Объект внешней обработки, подготовленный к работе с условным оформлением этой формы.
//
// Returns:
//  ExternalDataProcessorObject.Tsvetik - object ready for chaining
&AtServer
Function NewTsvetik()

	Return FormAttributeToValue("Object").Set(ConditionalAppearance);

EndFunction

&AtServer
Procedure ApplyConditionalAppearanceAtServer()

	Tsvetik = NewTsvetik();

	SetSafeMode(True);
	Execute(Result);

EndProcedure

&AtServer
Procedure GenerateCodeForCurrentAppearanceAtServer()

	Result = NewTsvetik().GenerateCode();

EndProcedure

&AtServer
Procedure ClearConditionalAppearanceAtServer()

	NewTsvetik().Clear();

EndProcedure

&AtServer
Procedure Test1AtServer()

	NewTsvetik()
		.Clear()
		.Item(Items.Attribute2)
			.AndGroup()
				.Equal(Items.Attribute2, 5)
			.BackColor(WebColors.LightSalmon);

	Result = "Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Items.Attribute2)
	|		.AndGroup()
	|			.Equal(Items.Attribute2, 5)
	|		.BackColor(WebColors.LightSalmon);";

EndProcedure

&AtServer
Procedure Test2AtServer()

	NewTsvetik()
		.Clear()
		.Item(Items.Attribute2)
			.AndGroup()
				.Equal(Items.Attribute2, 0)
				.NotEqual(Items.Attribute3, True)
				.OrGroup()
					.Equal(Items.Attribute4, True)
					.BeginsWith(Items.Attribute1, "a")
				.EndGroup()
			.EndGroup()
			.Appearance("BackColor", WebColors.Gold);

	Result = "Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Items.Attribute2)
	|		.AndGroup()
	|			.Equal(Items.Attribute2, 0)
	|			.NotEqual(Items.Attribute3, True)
	|			.OrGroup()
	|				.Equal(Items.Attribute4, True)
	|				.BeginsWith(Items.Attribute1, ""a"")
	|			.EndGroup()
	|		.EndGroup()
	|		.Appearance(""BackColor"", WebColors.Gold);";

EndProcedure

&AtServer
Procedure Test3AtServer()

	NewTsvetik()
		.Clear()
		.Item("Attribute1, Attribute2, Attribute5, Composition")
			.AndGroup()
				.Equal(Items.Attribute3, True)
			.Appearance("BackColor", WebColors.LightSalmon);

	Result = "Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(""Attribute1, Attribute2, Attribute5, Composition"")
	|		.AndGroup()
	|			.Equal(Items.Attribute3, True)
	|		.Appearance(""BackColor"", WebColors.LightSalmon);";

EndProcedure

&AtServer
Procedure Test4AtServer()

	NewTsvetik()
		.Clear()
		.Item(Items.Attribute2)
			.AndGroup()
				.Equal(Items.Attribute2, 0)
			.Appearance("BackColor", WebColors.LightSalmon);

	Result = "Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Items.Attribute2)
	|		.AndGroup()
	|			.Equal(Items.Attribute2, 0)
	|		.Appearance(""BackColor"", WebColors.LightSalmon);";

EndProcedure

&AtServer
Procedure Test5AtServer()

	Array = New Array;

	Array.Add("Attribute1");
	Array.Add(Items.Attribute2);
	Array.Add(Items.Composition);

	NewTsvetik()
		.Clear()
		.Item(Array)
			.AndGroup()
				.Equal(Items.Attribute2, 0)
			.Appearance("BackColor", WebColors.LightSalmon);

	Result = "Array = New Array;
	|
	|Array.Add(""Attribute1"");
	|Array.Add(Items.Attribute2);
	|Array.Add(Items.Composition);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Array)
	|		.AndGroup()
	|			.Equal(Items.Attribute2, 0)
	|		.Appearance(""BackColor"", WebColors.LightSalmon);";

EndProcedure

&AtServer
Procedure Test6AtServer()

	Array = New Array;

	Array.Add("Attribute1");
	Array.Add(Items.Attribute2);
	Array.Add(Items.CompositionAttribute2);

	NewTsvetik()
		.Clear()
		.Item(Array)
			.AndGroup()
				.Equal(Items.Attribute2, 0)
			.BackColor(WebColors.LightSalmon);

	Result = "Array = New Array;
	|
	|Array.Add(""Attribute1"");
	|Array.Add(Items.Attribute2);
	|Array.Add(Items.CompositionAttribute2);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Array)
	|		.AndGroup()
	|			.Equal(Items.Attribute2, 0)
	|		.BackColor(WebColors.LightSalmon);";

EndProcedure

&AtServer
Procedure Test7AtServer()

	Array = New Array;

	Array.Add(Items.Attribute1);
	Array.Add(Items.Attribute2);

	NewTsvetik()
		.Clear()
		.Item(Array)
			.AndGroup()
				.Equal(Items.Attribute3, True)
			.BackColor(WebColors.LightSalmon);

	NewTsvetik()
		.Item(Items.Composition)
			.AndGroup()
				.Equal(Items.CompositionAttribute3, True)
			.Appearance("BackColor", WebColors.LightSalmon);

	NewTsvetik()
		.Item(Items.CompositionAttribute3)
			.AndGroup()
				.Equal(Items.CompositionAttribute3, True)
			.Appearance("BackColor", WebColors.Aquamarine);

	Result = "Array = New Array;
	|
	|Array.Add(Items.Attribute1);
	|Array.Add(Items.Attribute2);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Array)
	|		.AndGroup()
	|			.Equal(Items.Attribute3, True)
	|		.BackColor(WebColors.LightSalmon);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Item(Items.Composition)
	|		.AndGroup()
	|			.Equal(Items.CompositionAttribute3, True)
	|		.Appearance(""BackColor"", WebColors.LightSalmon);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Item(Items.CompositionAttribute3)
	|		.AndGroup()
	|			.Equal(Items.CompositionAttribute3, True)
	|		.Appearance(""BackColor"", WebColors.Aquamarine);";

EndProcedure

&AtServer
Procedure Test8AtServer()

	NewTsvetik()
		.Clear()
		.Item(Items.Composition)
			.AndGroup()
				.Equal(Items.CompositionAttribute3, True)
			.Appearance("BackColor", WebColors.LightSalmon);

	Result = "Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Items.Composition)
	|		.AndGroup()
	|			.Equal(Items.CompositionAttribute3, True)
	|		.Appearance(""BackColor"", WebColors.LightSalmon);";

EndProcedure

// Runs the whole Tsvetik interface against the data of this form: every comparison type,
// every group type, every way of passing items and every appearance method.
// The generated code goes into Result, so GenerateCode is exercised at the same time.
// Ru: Прогоняет весь программный интерфейс на данных этой формы и заодно проверяет GenerateCode.
//
// Colors are set with New Color(R, G, B) everywhere except the three web colors proven in Test1-8:
// WebColors property names depend on the interface language, and a miss raises
// "Object field not found" at runtime. The flip side: an RGB color has no name,
// so GenerateCode substitutes the default color - WebColors.LightSalmon.
// Ru: Цвета заданы через New Color, кроме трех проверенных web-цветов: имена WebColors зависят
// Ru: от языка интерфейса. Обратная сторона - у RGB-цвета нет имени, и GenerateCode подставит
// Ru: цвет по умолчанию.
&AtServer
Procedure MegaTestAtServer()

	PrepareMegaTestData();

	Tsvetik = NewTsvetik().Clear();

	// 1. String comparisons. Every condition is true for "apple" - the item must be colored.
	//    Also: BackColor, TextColor, Font.
	Tsvetik
		.Item(Items.Attribute1)
			.AndGroup()
				.Filled(Items.Attribute1)
				.Contains(Items.Attribute1, "ppl")
				.NotContains(Items.Attribute1, "pear")
				.BeginsWith(Items.Attribute1, "a")
				.NotBeginsWith(Items.Attribute1, "p")
				.Like(Items.Attribute1, "a%")
				.NotLike(Items.Attribute1, "p%")
			.EndGroup()
			.BackColor(WebColors.LightSalmon)
			.TextColor(New Color(0, 0, 139))
			.Font(New Font(, , True));

	// 2. Number comparisons. Every condition is true for 42.
	//    Also: HorizontalAlign, MarkNegatives, Format through Appearance().
	Tsvetik
		.Item(Items.Attribute2)
			.AndGroup()
				.NotEqual(Items.Attribute2, 0)
				.Greater(Items.Attribute2, 0)
				.GreaterOrEqual(Items.Attribute2, 42)
				.Less(Items.Attribute2, 100)
				.LessOrEqual(Items.Attribute2, 42)
			.EndGroup()
			.HorizontalAlign(HorizontalAlign.Right)
			.MarkNegatives(True)
			.Appearance("Format", "ND=10; NFD=2");

	// 3. List comparisons. No explicit group - an implicit AndGroup is used.
	Tsvetik
		.Item(Items.Attribute5)
			.InList(Items.Attribute2, AllowedList())
			.NotInList(Items.Attribute2, ForbiddenList())
			.TextColor(New Color(0, 128, 0));

	// 4. Nested groups: AND( Equal, OR(...), NOT(...) ) returning back through EndGroup.
	Tsvetik
		.Item(Items.Attribute3)
			.AndGroup()
				.Equal(Items.Attribute3, True)
				.OrGroup()
					.Equal(Items.Attribute4, True)
					.Equal(Items.Attribute2, 42)
				.EndGroup()
				.NotGroup()
					.Equal(Items.Attribute4, True)
				.EndGroup()
			.EndGroup()
			.BackColor(WebColors.Gold);

	// 5. Items passed as a string with a list of names.
	Tsvetik
		.Item("Attribute1,Attribute2, Attribute5")
			.Equal(Items.Attribute3, True)
			.Appearance("TextColor", New Color(139, 0, 0));

	// 6. Items passed as an array: a string, a form field and a form table mixed together.
	ItemsArray = New Array;
	ItemsArray.Add("Attribute4");
	ItemsArray.Add(Items.Attribute3);
	ItemsArray.Add(Items.Composition);

	Tsvetik
		.Item(ItemsArray)
			.Equal(Items.Attribute2, 42)
			.BackColor(New Color(245, 245, 245));

	// 7. Table rows colored by a column value. ReadOnly and Enabled.
	Tsvetik
		.Item(Items.Composition)
			.Equal(Items.CompositionAttribute3, True)
			.BackColor(WebColors.Aquamarine)
			.ReadOnly(True);

	Tsvetik
		.Item(Items.CompositionAttribute2)
			.Less(Items.CompositionAttribute2, 0)
			.Enabled(False)
			.TextColor(New Color(255, 0, 0));

	// 8. Text replacement and incomplete mark on empty cells.
	Tsvetik
		.Item(Items.CompositionAttribute1)
			.NotFilled(Items.CompositionAttribute1)
			.Text("<not set>")
			.MarkIncomplete(True);

	// 9. Visible and Show go in pair: the first hides the item, the second hides the value output.
	Tsvetik
		.Item(Items.CompositionAttribute4)
			.NotGroup()
				.Equal(Items.CompositionAttribute3, True)
			.EndGroup()
			.Visible(False)
			.Show(False);

	// Hierarchy comparisons (InHierarchy, NotInHierarchy, InListByHierarchy, NotInListByHierarchy)
	// are not checked here: they need a reference field with hierarchy, and this form has
	// primitive types only. Check them on a form with a catalog:
	//
	//	.Item(Items.Products)
	//		.InHierarchy(Items.Products, ProductGroup)
	//		.BackColor(WebColors.LightSalmon);

	Result = Tsvetik.GenerateCode();

EndProcedure

// Fills the form attributes with values the mega test filters actually match.
// Ru: Заполняет реквизиты формы значениями, на которых отборы мегатеста срабатывают.
&AtServer
Procedure PrepareMegaTestData()

	Attribute1 = "apple";
	Attribute2 = 42;
	Attribute3 = True;
	Attribute4 = False;

	Attribute5.Clear();
	Attribute5.Add(1, "First");
	Attribute5.Add(2, "Second");

	Composition.Clear();

	NewRow = Composition.Add();
	NewRow.Attribute1 = "row 1";
	NewRow.Attribute2 = 10;
	NewRow.Attribute3 = True;
	NewRow.Attribute4 = True;

	NewRow = Composition.Add();
	NewRow.Attribute1 = "";
	NewRow.Attribute2 = -5;
	NewRow.Attribute3 = False;
	NewRow.Attribute4 = False;

	NewRow = Composition.Add();
	NewRow.Attribute1 = "row 3";
	NewRow.Attribute2 = 0;
	NewRow.Attribute3 = True;
	NewRow.Attribute4 = False;

	NewRow = Composition.Add();
	NewRow.Attribute1 = "";
	NewRow.Attribute2 = -100;
	NewRow.Attribute3 = False;
	NewRow.Attribute4 = True;

EndProcedure

// Values Attribute2 is expected to be in.
// Ru: Значения, в которые Attribute2 попадать должен.
//
// Returns:
//  Array Of Number
&AtServer
Function AllowedList()

	List = New Array;
	List.Add(1);
	List.Add(42);
	List.Add(100);

	Return List;

EndFunction

// Values Attribute2 is expected not to be in.
// Ru: Значения, в которые Attribute2 попадать не должен.
//
// Returns:
//  Array Of Number
&AtServer
Function ForbiddenList()

	List = New Array;
	List.Add(7);
	List.Add(8);

	Return List;

EndFunction

// Two hiding scenarios:
//  1. Attribute3 (form attribute) = True -> hide Attribute1 and the whole Composition.Attribute2 column.
//  2. Attribute3 of a table row = True -> replace the Attribute1 text in that row with "***".
// Ru: Два сценария сокрытия: по реквизиту формы и по реквизиту строки таблицы.
//
// The second one is a text replacement, not hiding: the value stays in the data,
// only what is shown in the cell changes.
// Ru: Второй сценарий - подмена текста, а не сокрытие: значение в данных остается.
&AtServer
Procedure VisibilityTestAtServer()

	PrepareVisibilityTestData();

	// THIS BLOCK DOES NOTHING AND IS KEPT AS A DEMONSTRATION OF THE LIMITATION.
	// Attribute1 is a plain form field, not a table item. Conditional appearance applies
	// Visible and Show only to table columns and to the table itself, so the filter works
	// but the field stays visible. No exception is raised.
	// A plain field can only be hidden by code: Items.Attribute1.Visible = Not Attribute3;
	// Ru: Блок ничего не делает: Visible и Show не работают на обычном поле формы.
	NewTsvetik()
		.Clear()
		.Item(Items.Attribute1)
			.Equal(Items.Attribute3, True)
			.Visible(False)
			.Show(False);

	NewTsvetik()
		.Item(Items.CompositionAttribute2)
			.Equal(Items.Attribute3, True)
			.Visible(False)
			.Show(False);

	NewTsvetik()
		.Item(Items.CompositionAttribute1)
			.Equal(Items.CompositionAttribute3, True)
			.Text("***");

	Result = "Tsvetik.Set(ConditionalAppearance)
	|	.Clear()
	|	.Item(Items.Attribute1)
	|		.Equal(Items.Attribute3, True)
	|		.Visible(False)
	|		.Show(False);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Item(Items.CompositionAttribute2)
	|		.Equal(Items.Attribute3, True)
	|		.Visible(False)
	|		.Show(False);
	|
	|Tsvetik.Set(ConditionalAppearance)
	|	.Item(Items.CompositionAttribute1)
	|		.Equal(Items.CompositionAttribute3, True)
	|		.Text(""***"");";

EndProcedure

// Prepares the form so both scenarios are visible: Attribute3 is off, so you can switch it
// and watch Attribute1 and column 2; part of the table rows have Attribute3 on.
// Ru: Готовит форму так, чтобы оба сценария было видно.
&AtServer
Procedure PrepareVisibilityTestData()

	Attribute1 = "visible while Attribute3 is off";
	Attribute3 = False;

	Composition.Clear();

	// Attribute1 of the table is a string of length 10, so the values are short.
	// Ru: Attribute1 в таблице - строка длиной 10, поэтому значения короткие.
	NewRow = Composition.Add();
	NewRow.Attribute1 = "regular 1";
	NewRow.Attribute2 = 100;
	NewRow.Attribute3 = False;

	NewRow = Composition.Add();
	NewRow.Attribute1 = "secret 1";
	NewRow.Attribute2 = 200;
	NewRow.Attribute3 = True;

	NewRow = Composition.Add();
	NewRow.Attribute1 = "regular 2";
	NewRow.Attribute2 = 300;
	NewRow.Attribute3 = False;

	NewRow = Composition.Add();
	NewRow.Attribute1 = "secret 2";
	NewRow.Attribute2 = 400;
	NewRow.Attribute3 = True;

EndProcedure

#EndRegion
