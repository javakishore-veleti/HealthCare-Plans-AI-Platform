#!/bin/bash

# =============================================================================
# Order Service - POM Files Generator
# =============================================================================

set -e

BASE_DIR="microservices/order-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Order Service - POM Files Generator                             ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# Create directory structure
mkdir -p "$BASE_DIR"/{order-common,order-dao,order-service-core,order-api-client,order-api-stub,order-api}/src/main/java
mkdir -p "$BASE_DIR"/{order-common,order-dao,order-service-core,order-api-client,order-api-stub,order-api}/src/main/resources
mkdir -p "$BASE_DIR"/{order-common,order-dao,order-service-core,order-api-client,order-api-stub,order-api}/src/test/java

# Parent POM
cat > "$BASE_DIR/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.0</version>
        <relativePath/>
    </parent>

    <groupId>com.healthcare.order</groupId>
    <artifactId>order-service</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>Order Service</name>
    <description>Healthcare Order Management Microservice</description>

    <modules>
        <module>order-common</module>
        <module>order-dao</module>
        <module>order-service-core</module>
        <module>order-api-client</module>
        <module>order-api-stub</module>
        <module>order-api</module>
    </modules>

    <properties>
        <java.version>21</java.version>
        <spring-cloud.version>2025.0.0</spring-cloud.version>
        <springdoc.version>2.8.8</springdoc.version>
        <mapstruct.version>1.6.3</mapstruct.version>
        <lombok.version>1.18.36</lombok.version>
        <testcontainers.version>1.20.4</testcontainers.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>

            <!-- Internal modules -->
            <dependency>
                <groupId>com.healthcare.order</groupId>
                <artifactId>order-common</artifactId>
                <version>${project.version}</version>
            </dependency>
            <dependency>
                <groupId>com.healthcare.order</groupId>
                <artifactId>order-dao</artifactId>
                <version>${project.version}</version>
            </dependency>
            <dependency>
                <groupId>com.healthcare.order</groupId>
                <artifactId>order-service-core</artifactId>
                <version>${project.version}</version>
            </dependency>
            <dependency>
                <groupId>com.healthcare.order</groupId>
                <artifactId>order-api-client</artifactId>
                <version>${project.version}</version>
            </dependency>
            <dependency>
                <groupId>com.healthcare.order</groupId>
                <artifactId>order-api-stub</artifactId>
                <version>${project.version}</version>
            </dependency>

            <!-- Plans Service Client -->
            <dependency>
                <groupId>com.healthcare.plans</groupId>
                <artifactId>plans-api-client</artifactId>
                <version>1.0.0-SNAPSHOT</version>
            </dependency>
            <dependency>
                <groupId>com.healthcare.plans</groupId>
                <artifactId>plans-common</artifactId>
                <version>1.0.0-SNAPSHOT</version>
            </dependency>

            <!-- Customer Service Client -->
            <dependency>
                <groupId>com.healthcare.customer</groupId>
                <artifactId>customer-api-client</artifactId>
                <version>1.0.0-SNAPSHOT</version>
            </dependency>
            <dependency>
                <groupId>com.healthcare.customer</groupId>
                <artifactId>customer-common</artifactId>
                <version>1.0.0-SNAPSHOT</version>
            </dependency>

            <dependency>
                <groupId>org.springdoc</groupId>
                <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
                <version>${springdoc.version}</version>
            </dependency>
            <dependency>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct</artifactId>
                <version>${mapstruct.version}</version>
            </dependency>
            <dependency>
                <groupId>org.testcontainers</groupId>
                <artifactId>testcontainers-bom</artifactId>
                <version>${testcontainers.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.11.0</version>
                    <configuration>
                        <source>${java.version}</source>
                        <target>${java.version}</target>
                        <annotationProcessorPaths>
                            <path>
                                <groupId>org.projectlombok</groupId>
                                <artifactId>lombok</artifactId>
                                <version>${lombok.version}</version>
                            </path>
                            <path>
                                <groupId>org.mapstruct</groupId>
                                <artifactId>mapstruct-processor</artifactId>
                                <version>${mapstruct.version}</version>
                            </path>
                            <path>
                                <groupId>org.projectlombok</groupId>
                                <artifactId>lombok-mapstruct-binding</artifactId>
                                <version>0.2.0</version>
                            </path>
                        </annotationProcessorPaths>
                    </configuration>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: pom.xml (parent)"

# order-common POM
cat > "$BASE_DIR/order-common/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.order</groupId>
        <artifactId>order-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>order-common</artifactId>
    <packaging>jar</packaging>

    <name>Order Service - Common</name>

    <dependencies>
        <dependency>
            <groupId>org.springframework.data</groupId>
            <artifactId>spring-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>jakarta.persistence</groupId>
            <artifactId>jakarta.persistence-api</artifactId>
        </dependency>
        <dependency>
            <groupId>jakarta.validation</groupId>
            <artifactId>jakarta.validation-api</artifactId>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-annotations</artifactId>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: order-common/pom.xml"

# order-dao POM
cat > "$BASE_DIR/order-dao/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.order</groupId>
        <artifactId>order-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>order-dao</artifactId>
    <packaging>jar</packaging>

    <name>Order Service - DAO</name>

    <dependencies>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-common</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

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
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: order-dao/pom.xml"

# order-service-core POM
cat > "$BASE_DIR/order-service-core/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.order</groupId>
        <artifactId>order-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>order-service-core</artifactId>
    <packaging>jar</packaging>

    <name>Order Service - Core</name>

    <dependencies>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-common</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-dao</artifactId>
        </dependency>

        <!-- Plans Service Client for inter-service calls -->
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-api-client</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.plans</groupId>
            <artifactId>plans-common</artifactId>
        </dependency>

        <!-- Customer Service Client for inter-service calls -->
        <dependency>
            <groupId>com.healthcare.customer</groupId>
            <artifactId>customer-api-client</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.customer</groupId>
            <artifactId>customer-common</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: order-service-core/pom.xml"

# order-api-client POM
cat > "$BASE_DIR/order-api-client/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.order</groupId>
        <artifactId>order-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>order-api-client</artifactId>
    <packaging>jar</packaging>

    <name>Order Service - API Client</name>

    <dependencies>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-common</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: order-api-client/pom.xml"

# order-api-stub POM
cat > "$BASE_DIR/order-api-stub/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.order</groupId>
        <artifactId>order-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>order-api-stub</artifactId>
    <packaging>jar</packaging>

    <name>Order Service - API Stub</name>

    <dependencies>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-common</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-service-core</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-api-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>
    </dependencies>

</project>
EOF
echo -e "${GREEN}✓${NC} Created: order-api-stub/pom.xml"

# order-api POM
cat > "$BASE_DIR/order-api/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare.order</groupId>
        <artifactId>order-service</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>order-api</artifactId>
    <packaging>jar</packaging>

    <name>Order Service - API</name>

    <dependencies>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-common</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-dao</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-service-core</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-api-client</artifactId>
        </dependency>
        <dependency>
            <groupId>com.healthcare.order</groupId>
            <artifactId>order-api-stub</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-database-postgresql</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        </dependency>

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
    </dependencies>

    <build>
        <plugins>
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
echo -e "${GREEN}✓${NC} Created: order-api/pom.xml"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Order Service POMs Created!                                     ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run setup-order-service-java-part1.sh${NC}"