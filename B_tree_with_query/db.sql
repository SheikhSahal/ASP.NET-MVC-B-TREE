USE [PSL]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeName] [nvarchar](50) NULL,
	[ManagerID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Login]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Login](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[User_name] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[C_Password] [varchar](50) NULL,
	[Company] [varchar](50) NULL CONSTRAINT [df_Company]  DEFAULT ('PSL'),
 CONSTRAINT [PK_Login_1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Menus]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Menus](
	[Menu_id] [int] NOT NULL,
	[Menu_name] [varchar](50) NULL,
	[Menu_Parent_id] [int] NULL,
 CONSTRAINT [PK_Menus] PRIMARY KEY CLUSTERED 
(
	[Menu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RIghts]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RIghts](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Menu_id] [int] NULL,
	[User_name] [varchar](50) NULL,
	[User_Insert] [char](1) NULL,
	[User_update] [char](1) NULL,
	[User_delete] [char](1) NULL,
 CONSTRAINT [PK_RIghts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User_Privilege]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User_Privilege](
	[User_id] [varchar](50) NULL,
	[Menu_id] [int] NULL,
	[Grant_YN] [char](1) NULL,
	[User_Insert] [char](1) NULL,
	[User_Update] [char](1) NULL,
	[User_Delete] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD FOREIGN KEY([ManagerID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[User_Privilege]  WITH CHECK ADD  CONSTRAINT [FK_User_Privilege_Menus] FOREIGN KEY([Menu_id])
REFERENCES [dbo].[Menus] ([Menu_id])
GO
ALTER TABLE [dbo].[User_Privilege] CHECK CONSTRAINT [FK_User_Privilege_Menus]
GO
/****** Object:  StoredProcedure [dbo].[B_tree]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[B_tree]
as 
with r as (
      select menu_id, menu_name, menu_parent_id, depth=0 ,sort=cast(Menu_id as varchar(max))
      from Menus 
      where Menu_Parent_id is null
      union all
      select pc.Menu_id, pc.Menu_name, pc.Menu_Parent_id, depth=r.depth+1 ,sort=r.sort+cast(pc.Menu_id as varchar(30))
      from r 
      inner join Menus pc on r.Menu_id=pc.Menu_Parent_id
      where r.depth<32767

)
select  r.Menu_id,tree=replicate('',r.depth*3)+r.Menu_name, r.Menu_Parent_id
from r 
order by sort;


GO
/****** Object:  StoredProcedure [dbo].[each_user_menu]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[each_user_menu]
@username varchar(100)
as
select m.Menu_id d_id,u.Menu_id , m.menu_name , m.menu_parent_id , u.User_id from Menus m
full outer join  User_Privilege u on m.Menu_id = u.Menu_id
where u.User_id = @username
or u.Menu_id is null
union all
select  u.Menu_id d_id,null Menu_id , m.Menu_name , m.Menu_Parent_id , null user_id from Menus m, User_Privilege u
where u.User_id <> @username
and m.Menu_id = u.Menu_id


GO
/****** Object:  StoredProcedure [dbo].[individual_menu]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[individual_menu] 
@user_name varchar(50) 
as
begin
with r as (
select u.menu_id, m.menu_name, m.menu_parent_id , u.User_id, depth=0 ,sort=cast(m.Menu_id as varchar(max))
      from Menus m , User_Privilege u
      where m.Menu_Parent_id is null
	  and u.Menu_id = m.Menu_id
	  and u.User_id = @user_name
      union all
      select pc.Menu_id, pc.Menu_name, pc.Menu_Parent_id,ac.user_id, depth=r.depth+1 ,sort=r.sort+cast(pc.Menu_id as varchar(30))
      from r 
      inner join Menus pc on r.Menu_id=pc.Menu_Parent_id
	  inner join User_Privilege ac on r.Menu_id=ac.Menu_id
      where r.depth<32767
)
select  r.Menu_id,tree=replicate('',r.depth*3)+r.Menu_name, r.Menu_Parent_id
from r
order by sort;

end
GO
/****** Object:  StoredProcedure [dbo].[user_Menu]    Script Date: 22-Apr-19 6:38:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[user_Menu]
--@username varchar(50)
as 
begin
select u.User_id , u.Menu_id , m.Menu_name , m.Menu_Parent_id
 from User_Privilege u , Menus m
 where u.Menu_id = m.Menu_id
 --and u.User_id = @username
 end
GO
