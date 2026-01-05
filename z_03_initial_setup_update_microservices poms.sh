#!/bin/bash

# =============================================================================
# Plans Service - POM Files Generator
# =============================================================================
# Updates all blank pom.xml files in plans-service with proper configuration
# =============================================================================

set -e

BASE_DIR="microservices/plans-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Plans Service - POM Files Generator                             ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# plans-dao/pom.xml
# =============================================================================
echo -e "${YELLOW}Creating: $BASE_DIR/plans-dao/pom.xml${NC}"
cat > "$BASE_DIR/plans-dao/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.plans</groupId>
        <artifactId>plans-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>plans-dao</artifactId>
    <packaging>jar</packaging>

    <name>Plans Service - DAO</name>
    <description>Data Access Layer - Repositories and DB configurations</description>

    <dependencies>
        <!-- Internal dependency -->
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-common</artifactId>
        </dependency>

        <!-- Spring Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- PostgreSQL Driver -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: $BASE_DIR/plans-dao/pom.xml"

# =============================================================================
# plans-service-core/pom.xml
# =============================================================================
echo -e "${YELLOW}Creating: $BASE_DIR/plans-service-core/pom.xml${NC}"
cat > "$BASE_DIR/plans-service-core/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.plans</groupId>
        <artifactId>plans-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>plans-service-core</artifactId>
    <packaging>jar</packaging>

    <name>Plans Service - Core</name>
    <description>Business Logic Layer - Service implementations</description>

    <dependencies>
        <!-- Internal dependencies -->
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-common</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-dao</artifactId>
        </dependency>

        <!-- Spring Context -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>

        <!-- Spring Transaction -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
        </dependency>

        <!-- MapStruct for mapping -->
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
        </dependency>

        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: $BASE_DIR/plans-service-core/pom.xml"

# =============================================================================
# plans-api-client/pom.xml
# =============================================================================
echo -e "${YELLOW}Creating: $BASE_DIR/plans-api-client/pom.xml${NC}"
cat > "$BASE_DIR/plans-api-client/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.plans</groupId>
        <artifactId>plans-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>plans-api-client</artifactId>
    <packaging>jar</packaging>

    <name>Plans Service - API Client</name>
    <description>API Client interfaces and Feign clients for inter-service communication</description>

    <dependencies>
        <!-- Internal dependency - DTOs only -->
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-common</artifactId>
        </dependency>

        <!-- Spring Web (for annotations) -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
        </dependency>

        <!-- Spring Cloud OpenFeign -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>

        <!-- Jackson for JSON -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: $BASE_DIR/plans-api-client/pom.xml"

# =============================================================================
# plans-api-stub/pom.xml
# =============================================================================
echo -e "${YELLOW}Creating: $BASE_DIR/plans-api-stub/pom.xml${NC}"
cat > "$BASE_DIR/plans-api-stub/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.plans</groupId>
        <artifactId>plans-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>plans-api-stub</artifactId>
    <packaging>jar</packaging>

    <name>Plans Service - API Stub</name>
    <description>API Stub implementations - bridges API interfaces to business logic</description>

    <dependencies>
        <!-- Internal dependencies -->
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-common</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-service-core</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-api-client</artifactId>
        </dependency>

        <!-- Spring Context -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: $BASE_DIR/plans-api-stub/pom.xml"

# =============================================================================
# plans-api/pom.xml (Spring Boot Application)
# =============================================================================
echo -e "${YELLOW}Creating: $BASE_DIR/plans-api/pom.xml${NC}"
cat > "$BASE_DIR/plans-api/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.plans</groupId>
        <artifactId>plans-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>plans-api</artifactId>
    <packaging>jar</packaging>

    <name>Plans Service - API</name>
    <description>REST API Layer - Controllers and Spring Boot Application</description>

    <dependencies>
        <!-- Internal dependencies -->
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-common</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-dao</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-service-core</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-api-client</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-api-stub</artifactId>
        </dependency>

        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot Actuator -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Spring Boot Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Spring Data JPA (pulled from dao, but needed for auto-config) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- PostgreSQL Driver -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Flyway for migrations -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-database-postgresql</artifactId>
        </dependency>

        <!-- OpenAPI / Swagger -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- Spring Boot Maven Plugin - only in this module -->
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: $BASE_DIR/plans-api/pom.xml"

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}                    Plans Service POMs Generation Complete!                   ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Created/Updated:${NC}"
echo -e "  ✓ plans-dao/pom.xml"
echo -e "  ✓ plans-service-core/pom.xml"
echo -e "  ✓ plans-api-client/pom.xml"
echo -e "  ✓ plans-api-stub/pom.xml"
echo -e "  ✓ plans-api/pom.xml"
echo ""
echo -e "${YELLOW}Already existed (not modified):${NC}"
echo -e "  • plans-service/pom.xml (parent)"
echo -e "  • plans-common/pom.xml"
echo ""
echo -e "${YELLOW}Module Dependency Chain:${NC}"
echo -e "  plans-common"
echo -e "       ↓"
echo -e "  plans-dao"
echo -e "       ↓"
echo -e "  plans-service-core"
echo -e "       ↓"
echo -e "  plans-api-client"
echo -e "       ↓"
echo -e "  plans-api-stub"
echo -e "       ↓"
echo -e "  plans-api (Spring Boot App)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Run: cd microservices/plans-service && mvn clean install"
echo -e "  2. Add Java source files to each module"
echo ""