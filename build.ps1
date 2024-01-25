$PrevPath = (Get-Location).Path
$RootPath = $PSScriptRoot
Set-Location -path $RootPath


class Source {
	[string]$Origin
	[string]$Target

	Source() { $this.Init(@{}) }
	Source([hashtable]$Properties) { $this.Init($Properties) }
	Source([string]$Origin, [string]$Target) {
		$this.Init(@{
			Origin = $Origin;
			Target = $Target;
		})
	}
	[void] Init([hashtable]$Properties) {
		foreach($Property in $Properties.Keys) {
			$this.$Property = $Properties.$Property
		}
	}
}
class Dependency {
	[string]$Name
	[string]$Path
	[string]$Task
	[Source[]]$Sources

	Dependency() { $this.Init(@{}) }
	Dependency([hashtable]$Properties) { $this.Init($Properties) }
	Dependency([string]$Name, [string]$Path, [string]$Task, [Source[]]$Sources) {
		$this.Init(@{
			Name = $Name;
			Path = $Path;
			Task = $Task;
			Sources = $Sources;
		})
	}
	[void] Init([hashtable]$Properties) {
		foreach($Property in $Properties.Keys) {
			$this.$Property = $Properties.$Property
		}
	}

	[void] Build() {
		Set-Location -path $this.Path
		Write-Host "Building dependency $($this.Name)"
		if($this.Task) {
			& ./$($this.Task)
		}
		foreach($Source in $this.Sources) {
			Write-Host "`tImporting $($Source.Origin)"
			Copy-Item -path "$($Source.Origin)" -destination "$($Source.Target)" -force
		}
	}
}
class Component {
	[string]$Name
	[string]$Path
	[string]$File

	Component() { $this.Init(@{}) }
	Component([hashtable]$Properties) { $this.Init($Properties) }
	Component([string]$Name, [string]$Path, [string]$File) {
		$this.Init(@{
			Name = $Name;
			Path = $Path;
			File = $File;
		})
	}
	[void] Init([hashtable]$Properties) {
		foreach($Property in $Properties.Keys) {
			$this.$Property = $Properties.$Property
		}
	}

	[void] Build() {
		Set-Location -path $this.Path
		Write-Host "Compiling module $($this.Name)"
		& rojo build "$($this.Name)" -o "$($this.File)"
	}
}


$Project = @{
	Name = "ProfileService";
	Root = $RootPath;
}
foreach($Element in @(
	
	[Dependency]::new(@{
		Name = "Class";
		Path = "C:/Dev/Roblox/RbxlClass";
		Task = "build.ps1";
		Sources = @(
			[Source]::new(@{
				Origin = "build/Class.rbxm";
				Target = "$($Project.Root)/test/src/packages/common";
			});
		);
	});
	[Dependency]::new(@{
		Name = "Array";
		Path = "C:/Dev/Roblox/RbxlArray";
		Task = "build.ps1";
		Sources = @(
			[Source]::new(@{
				Origin = "build/Array.rbxm";
				Target = "$($Project.Root)/test/src/packages/common";
			});
		);
	});
	[Dependency]::new(@{
		Name = "Future";
		Path = "C:/Dev/Roblox/RbxlFuture";
		Task = "build.ps1";
		Sources = @(
			[Source]::new(@{
				Origin = "build/Future.rbxm";
				Target = "$($Project.Root)/test/src/packages/common";
			});
		);
	});
	[Dependency]::new(@{
		Name = "Parcel";
		Path = "C:/Dev/Roblox/RbxlParcel";
		Task = "build.ps1";
		Sources = @(
			[Source]::new(@{
				Origin = "build/Parcel.rbxm";
				Target = "$($Project.Root)/test/src/packages/common";
			});
			[Source]::new(@{
				Origin = "build/ParcelClient.rbxm";
				Target = "$($Project.Root)/test/src/run/client";
			});
			[Source]::new(@{
				Origin = "build/ParcelServer.rbxm";
				Target = "$($Project.Root)/test/src/run/server";
			});
		);
	});
	[Dependency]::new(@{
		Name = "DataService";
		Path = "C:/Dev/Roblox/RbxlDataService";
		Task = "build.ps1";
		Sources = @(
			[Source]::new(@{
				Origin = "build/DataService.rbxm";
				Target = "$($Project.Root)/test/src/packages/server";
			});
		);
	});
	[Component]::new(@{
		Name = "main";
		Path = "$($Project.Root)";
		File = "build/$($Project.Name).rbxm";
	});
	[Dependency]::new(@{
		Name = "ProfileService";
		Path = "$($Project.Root)";
		Sources = @(
			[Source]::new(@{
				Origin = "build/ProfileService.rbxm";
				Target = "$($Project.Root)/test/src/packages/server";
			});
		);
	});
)) {
	$Element.Build()
}


Set-Location -path $PrevPath